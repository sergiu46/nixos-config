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

  # Networking
  networking = {
    hostName = "Portable-NIX";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  # Bootloader, kernel, and initrd
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
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
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
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
        "background_gc=on"
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
    memoryPercent = 50;
  };

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
  };

  # Power management
  powerManagement.enable = true;

  # Services
  services = {
    fstrim.enable = true; # Periodic TRIM for SSDs
    blueman.enable = true; # Bluetooth applet
    power-profiles-daemon.enable = true; # Power profile switching
    thermald.enable = true; # Intel thermal daemon
    tlp.enable = false; # Disabled in favor of other power tools
    upower.enable = true; # Battery monitoring
    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
    ];

  };

  # Systemd customizations
  systemd = {
    mounts = [
      {
        where = "/var/lib/systemd";
        what = "tmpfs";
        type = "tmpfs";
        options = "mode=0755,size=20M";
      }
    ];
    services."systemd-tmpfiles-clean".enable = true;
    coredump.enable = false;
  };

  # Disable documentation to save space and build time
  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # System state version
  system.stateVersion = stateVersion;
}
