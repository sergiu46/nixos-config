{
  pkgs,
  lib,
  modulesPath,
  stateVersion,
  userVars,
  configName,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/sync-config.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/tmpfs.nix
    ../../modules/disable-tpm.nix
    ../../modules/zramSwap.nix
  ];

  # --- Boot & Kernel ---
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Load KVM modules for both vendors so virtualization works everywhere
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];
    kernelParams = [
      "usbcore.autosuspend=-1"
      "initcall_parallel=1" # Faster boot
      "scsi_mod.use_blk_mq=1" # Multi-queue for storage
      "intel_pstate=active"
      "amd_pstate=active"
    ];

    initrd = {
      checkJournalingFS = true;
      systemd.enable = true;
      # Broad hardware support for the USB stick to boot anywhere
      availableKernelModules = [
        "ahci"
        "ehci_pci"
        "mmc_block"
        "mmc_core"
        "nvme"
        "ohci_pci"
        "rtsx_pci"
        "sd_mod"
        "sdhci_acpi"
        "sdhci_pci"
        "sr_mod"
        "uas"
        "uhci_hcd"
        "usb_storage"
        "xhci_pci"
        "atkbd"
        "hid_generic"
      ];
    };

    kernel.sysctl = {
      "vm.dirty_background_bytes" = 16777216;
      "vm.dirty_bytes" = 33554432;
      "vm.dirty_writeback_centisecs" = 3000;
      "vm.dirty_expire_centisecs" = 3000;
      "vm.swappiness" = 60;
      "vm.vfs_cache_pressure" = 50;
      "kernel.core_pattern" = "|/bin/false";
    };

    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };

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
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/${userVars.f2fs.label}";
      fsType = "f2fs";
      options = userVars.f2fs.optsList;
    };

    "/boot" = {
      device = "/dev/disk/by-label/${userVars.efiLabel}";
      fsType = "vfat";
    };
  };

  # --- Networking & Privacy ---
  networking = {
    hostName = configName;
    useDHCP = lib.mkDefault true;
    usePredictableInterfaceNames = false;
    networkmanager = {
      enable = true;
      settings = {
        connectivity = {
          uri = "http://nmcheck.gnome.org/check_network_status.txt";
          response = "NetworkManager is online";
          interval = 300;
        };
      };
      connectionConfig."connection.stable-id" = "\${CONNECTION}";
      wifi = {
        scanRandMacAddress = true;
        macAddress = "stable";
      };
      ethernet.macAddress = "random";
    };
  };

  services.gnome.core-shell.enable = true;

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
        libvdpau-va-gl # VDPAU wrapper
        libva # Base LibVA
        # AMD
        rocmPackages.clr.icd # OpenCL for AMD
      ];

      # 32-bit support (Steam, Wine)
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
  };

  services = {
    haveged.enable = true; # randomize service
    locate.enable = false; # disable file indexing
    xserver.wacom.enable = true; # Wacom tablet support

    # Universal Video Drivers
    # Order matters! Specific drivers first, fallbacks last.
    xserver.videoDrivers = [
      "amdgpu" # Modern AMD
      "radeon" # Older AMD (optional but good for very old PCs)
      "nouveau" # Nvidia Open Source
      "modesetting" # Intel & Generic fallback
      "fbdev" # Last resort
    ];

    udev.extraRules = ''
      # BFQ for USB/SSD
      ACTION=="add|change", \
        KERNEL=="sd[a-z]*|mmcblk[0-9]*|nvme[0-9]*", \
        ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="bfq"

      # Ghost Mode: Hide internal drives of the host machine
      SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';
  };

  # extra firmware packages
  environment.systemPackages = with pkgs; [
    # Firmware
    linux-firmware
    alsa-firmware
    sof-firmware
  ];

  systemd = {
    coredump.enable = false;
    targets.hibernate.enable = false;
    targets.hybrid-sleep.enable = false;
    mounts = [
      {
        where = "/var/lib/systemd";
        what = "tmpfs";
        type = "tmpfs";
        options = "mode=0755,size=20M";
      }
    ];

  };

  documentation.enable = false;
  system.stateVersion = stateVersion;
}
