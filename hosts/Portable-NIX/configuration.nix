{
  pkgs,
  lib,
  modulesPath,
  stateVersion,
  ...
}:

{
  # Imports
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/sync-config.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/tmpfs.nix

  ];

  # Networking & Privacy (Ghost Mode)
  networking = {
    hostName = "Portable-NIX";
    useDHCP = lib.mkDefault true;
    # Disable predictable names so wifi is always 'wlan0' regardless of hardware
    usePredictableInterfaceNames = false;
    networkmanager = {
      enable = true;
      # Makes connection IDs unique to each boot to avoid tracking
      connectionConfig."connection.stable-id" = "\${CONNECTION}/\${BOOT}";
      # MAC Address Randomization (Privacy)
      wifi = {
        scanRandMacAddress = true; # Randomize MAC during scanning
        macAddress = "random"; # Randomize MAC when connected
      };
      ethernet.macAddress = "random";
    };
  };

  # Bootloader, kernel, and initrd
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];
    kernelParams = [
      "initcall_parallel=1"
      "scsi_mod.use_blk_mq=1"
      "pcie_aspm=off"
    ];
    extraModulePackages = [ ];
    initrd = {
      systemd.enable = true;
      kernelModules = [ ];
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
      # 1. Background write triggers (Lower is better for slow USB)
      "vm.dirty_background_bytes" = 16777216; # 16MB
      "vm.dirty_bytes" = 33554432; # 32MB
      # 2. Swappiness (Higher is better when using ZRAM)
      "vm.swappiness" = 100;
      # 3. Cache Pressure (Increase to keep RAM free)
      "vm.vfs_cache_pressure" = 100;
    };

    loader = {
      systemd-boot = {
        enable = true;
      };
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
      "squashfs"
      "vfat"
      "xfs"
    ];
  };

  # Filesystems
  # Format NIX-ROOT partition with this command. Set the right device at the end.
  # sudo mkfs.f2fs -f -l NIX-ROOT -O extra_attr,inode_checksum,sb_checksum,compression -o 5 /dev/sda3
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIX-ROOT";
      fsType = "f2fs";
      options = [
        "noatime"
        "lazytime"
        "background_gc=sync"
        "compress_algorithm=lz4"
        "compress_chksum"
        "compress_mode=fs"
        "compress_extension=*"
        "atgc"
        "gc_merge"
        "flush_merge"
        "checkpoint_merge"
        "inline_xattr"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIX-BOOT";
      fsType = "vfat";
    };

  };

  # ZRAM swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 60;
    priority = 100;
  };
  swapDevices = [ ];

  # Hardware and firmware
  hardware = {
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
    enableAllFirmware = true;
    firmware = [ pkgs.linux-firmware ];
    graphics.enable = true;
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };

  # Power management
  powerManagement.enable = true;

  # Services
  services = {
    fstrim.enable = true; # Periodic TRIM for SSDs
    blueman.enable = true; # Bluetooth applet
    power-profiles-daemon.enable = true; # Power profile switching
    thermald.enable = false; # Intel thermal daemon
    tlp.enable = false; # Disabled in favor of other power tools
    upower.enable = true; # Battery monitoring
    locate.enable = false;
    haveged.enable = true;
    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
      "vesa"
    ];
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
      SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';
  };

  # Add hardware acceleration for various vendors
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # For newer Intel (Broadwell+)
    intel-vaapi-driver # REPLACEMENT for vaapiIntel (For older Intel)
    libva-vdpau-driver # REPLACEMENT for vaapiVdpau (For Nvidia/Generic)
    libvdpau-va-gl # Bridges VDPAU to VAAPI
  ];

  # Disable documentation to save space and build time
  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # Systemd Customizations
  systemd = {
    mounts = [
      {
        where = "/var/lib/systemd";
        what = "tmpfs";
        type = "tmpfs";
        options = "mode=0755,size=20M";
      }
    ];
  };

  # Disable TPM
  boot.blacklistedKernelModules = [
    "tpm"
    "tpm_tis"
    "tpm_tis_core"
    "tpm_crb"
  ];
  systemd = {
    tpm2.enable = false;
    units."dev-tpmrm0.device".enable = false;
    services.tailscaled.environment.TS_ENCRYPT_STATE = "false";
  };
  boot.initrd.systemd.tpm2.enable = false;
  security.tpm2.enable = false;

  # System state version
  system.stateVersion = stateVersion;
}
