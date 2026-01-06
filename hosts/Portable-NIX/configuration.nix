{
  pkgs,
  lib,
  modulesPath,
  inputs,
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
        configurationLimit = 5;
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
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "50%";
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIX-ROOT";
      fsType = "f2fs";
      options = [
        "background_gc=on"
        "compress_algorithm=zstd:3"
        "compress_chksum"
        "discard"
        "noatime"
        "lazytime"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIX-BOOT";
      fsType = "vfat";
    };
    "/tmp" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=1777"
      ];
    };
    "/var/lib/nix" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0755"
      ];
    };
    "/var/cache" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0755"
      ];
    };
    "/var/spool" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0755"
      ];
    };
    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0755"
      ];
    };
    "/var/tmp" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=1777"
      ];
    };
    "/root/.cache" = {
      fsType = "tmpfs";
      options = [ "size=50%" ];
    };
    "/home/sergiu/.cache" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0777"
      ];
    };
    "/home/sergiu/.var/app/com.microsoft.Edge/cache" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0777"
      ];
    };
    "/home/sergiu/.var/app/com.github.iwalton3.jellyfin-media-player/cache" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0777"
      ];
    };
  };

  # Nix build temporary directory
  environment.variables.NIX_BUILD_TMPDIR = "/tmp/nix-build";

  # Disable trash
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/nautilus/preferences" = {
            confirm-trash = true; # ask before deleting
            enable-delete = true; # enables permanent delete
          };
        };
      }
    ];
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
    journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=50M
    '';
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/scheduler}="bfq"
    '';
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
