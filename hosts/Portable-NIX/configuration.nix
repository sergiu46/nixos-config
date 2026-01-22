{
  pkgs,
  lib,
  modulesPath,
  stateVersion,
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
      "initcall_parallel=1" # Faster boot
      "scsi_mod.use_blk_mq=1" # Multi-queue for storage
      "intel_pstate=active"
      "amd_pstate=active"
    ];

    initrd = {
      checkJournalingFS = true;
      systemd.enable = true;
      # Disable TPM
      systemd.tpm2.enable = false;
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

    # Optimized for running off a slow USB stick
    kernel.sysctl = {
      "vm.dirty_background_bytes" = 16777216; # 16MB
      "vm.dirty_bytes" = 33554432; # 32MB
      "vm.swappiness" = 100; # Aggressively use ZRAM
      "vm.vfs_cache_pressure" = 50; # Keep directory structure in RAM
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

    # Disable TPM modules
    blacklistedKernelModules = [
      "tpm"
      "tpm_tis"
      "tpm_tis_core"
      "tpm_crb"
    ];
  };

  # --- Filesystems ---
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/Portable-NIX";
      fsType = "f2fs";
      options = [
        "noatime"
        "lazytime"
        "background_gc=sync"
        "compress_algorithm=zstd:6"
        "compress_chksum"
        "compress_mode=fs"
        "compress_extension=*"
        "atgc"
        "gc_merge"
        "flush_merge"
        "checkpoint_merge"
        "inline_xattr"
        "inline_data"
        "inline_dentry"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXEFI";
      fsType = "vfat";
    };
  };

  # --- Networking & Privacy ---
  networking = {
    hostName = "Portable-NIX";
    useDHCP = lib.mkDefault true;
    usePredictableInterfaceNames = false;
    networkmanager = {
      enable = true;
      connectionConfig."connection.stable-id" = "\${CONNECTION}";
      wifi = {
        scanRandMacAddress = true;
        macAddress = "random";
      };
      ethernet.macAddress = "random";
    };
  };

  # --- ZRAM (RAM Compression) ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    # Graphics Acceleration
    graphics = {
      enable = true;
      enable32Bit = true; # Check 1: This must be INSIDE graphics
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
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*|nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
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

  # --- Security & Systemd ---
  security.tpm2.enable = false;

  systemd = {
    coredump.enable = false;
    targets.hibernate.enable = false;
    targets.hybrid-sleep.enable = false;
    # TPM Disable
    tpm2.enable = false;
    units."dev-tpmrm0.device".enable = false;
    services.tailscaled.environment.TS_ENCRYPT_STATE = "false";
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
