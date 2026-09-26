{
  pkgs,
  lib,
  modulesPath,
  userVars,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # --- Boot & Kernel ---
  boot = {
    # Kernel selection
    kernelPackages = pkgs.linuxPackages_latest;
    # Loaded after root is mounted - for virtualization
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    # Bootloader
    loader = {
      systemd-boot.enable = true;
      timeout = 2; # Wait time for menu
      efi = {
        canTouchEfiVariables = false; # Don't rewrite NVRAM on unfamiliar firmware
        efiSysMountPoint = "/boot";
      };
    };

    # Initrd: early boot environment that finds, unlocks, and mounts root
    initrd = {
      systemd.enable = true;
      checkJournalingFS = true;

      # Fast decompression over smaller image size
      compressor = "zstd";
      compressorArgs = [
        "-1"
        "-T0"
      ];

      # Skip NixOS's built-in module list (legacy internal SATA/PATA chipset
      includeDefaultModules = false;
      availableKernelModules = [
        # USB storage transport (the drive itself)
        "uas"
        "usb_storage"
        "sd_mod"

        # USB host controllers - varies by host machine
        "ehci_pci"
        "ohci_pci"
        "uhci_hcd"
        "xhci_pci"

        # SD/MMC card readers
        "mmc_block"
        "mmc_core"
        "rtsx_pci"
        "sdhci_acpi"
        "sdhci_pci"

        # Keyboard input for the LUKS prompt
        "usbhid"
        "hid_generic"
        "atkbd"
        "i8042"
      ];
    };

    # Kernel parameters
    kernelParams = [
      "intel_pstate=active"
      "amd_pstate=active"
      "usbcore.autosuspend=-1"
      "fsck.mode=skip" # Disable file system check during boot
      "scsi_mod.use_blk_mq=1" # Multi-queue for storage
      "scsi_mod.scan=async"
      "async_probe"
    ];

    # Kernel runtime tuning
    kernel.sysctl = {
      # Write batching - critical since no TRIM for wear leveling
      "vm.dirty_background_bytes" = 134217728; # 128MB
      "vm.dirty_bytes" = 536870912; # 512MB
      # Write intervals
      "vm.dirty_expire_centisecs" = 6000; # 45 seconds
      "vm.dirty_writeback_centisecs" = 3000; # 15 seconds
      # Disable core dumps
      "kernel.core_pattern" = "|/bin/false";
    };

    # Filesystem support
    supportedFilesystems = lib.mkAfter [
      "btrfs"
      "ext4"
      "f2fs"
      "ntfs"
      "vfat"
      "xfs"
    ];
  };

  # --- Filesystems ---
  boot.initrd.luks.devices.${userVars.f2fs.label} = {
    device = "/dev/disk/by-label/${userVars.f2fs.label}-CRYPT";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/${userVars.f2fs.label}";
    fsType = "f2fs";
    options = userVars.f2fs.optsList;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/${userVars.efiLabel}";
    fsType = "vfat";
  };

  # --- Hardware ---
  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    # Graphics Acceleration
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Intel
        intel-media-driver # Modern Intel (Broadwell+)
        intel-vaapi-driver # Older Intel
        # Universal / Core (Crucial for smooth daily tasks on all GPUs)
        mesa
        vulkan-loader
        vulkan-validation-layers
        libva # Base LibVA
        libvdpau-va-gl # VDPAU wrapper
        # AMD
        rocmPackages.clr.icd # OpenCL for AMD
      ];

      # 32-bit support (Steam, Wine, etc.)
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        mesa
        vulkan-loader
        libvdpau-va-gl
      ];
    };
  };

  # --- Services ---
  services = {
    gnome.core-shell.enable = true;

    haveged.enable = true; # randomize service
    locate.enable = false; # disable file indexing
    xserver.wacom.enable = true; # Wacom tablet support

    # Video Drivers. Order matters! Specific drivers first, fallbacks last.
    xserver.videoDrivers = [
      "amdgpu" # Modern AMD
      "radeon" # Older AMD
      "nouveau" # Nvidia Open Source
      "modesetting" # Intel & Generic fallback
    ];
  };

  # Extra firmware packages
  environment.systemPackages = with pkgs; [
    linux-firmware
    alsa-firmware
    sof-firmware
  ];

  # --- EFI Partition Flag Management ---
  # Flip ESP Flags on Boot
  systemd.services.activate-efi-on-boot = {
    description = "Set /boot to ACTIVE (esp) at boot";
    after = [ "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "efi-on" ''
        DEV_PATH=$(${pkgs.util-linux}/bin/findmnt -vno SOURCE /boot)
        PARENT_DISK=$(${pkgs.util-linux}/bin/lsblk -no pkname "$DEV_PATH")
        PART_NUM=$(${pkgs.util-linux}/bin/lsblk -no PARTN "$DEV_PATH")
        ${pkgs.parted}/bin/parted -s /dev/"$PARENT_DISK" set "$PART_NUM" esp on
      '';
      RemainAfterExit = true;
    };
  };

  # Flip ESP Flags on Shutdown
  systemd.services.deactivate-efi-on-shutdown = {
    description = "Set /boot to HIDDEN at shutdown";
    after = [ "local-fs.target" ];
    before = [
      "shutdown.target"
      "umount.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = pkgs.writeShellScript "efi-off" ''
        DEV_PATH=$(${pkgs.util-linux}/bin/findmnt -vno SOURCE /boot)
        PARENT_DISK=$(${pkgs.util-linux}/bin/lsblk -no pkname "$DEV_PATH")
        PART_NUM=$(${pkgs.util-linux}/bin/lsblk -no PARTN "$DEV_PATH")        
        ${pkgs.parted}/bin/parted -s /dev/"$PARENT_DISK" set "$PART_NUM" esp off
        ${pkgs.parted}/bin/parted -s /dev/"$PARENT_DISK" set "$PART_NUM" hidden on
      '';
    };
  };

  # --- systemd mounts ---
  systemd.mounts = [
    {
      where = "/var/lib/systemd";
      what = "tmpfs";
      type = "tmpfs";
      options = "mode=0755,size=20M";
    }
  ];

  # --- Misc ---
  documentation.enable = false;
}
