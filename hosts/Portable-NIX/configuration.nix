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
  # External modules for hardware detection, base system, and custom configs
  imports = [
    # Universal hardware support and automatic module detection
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")

    # Custom modules
    ./sync-config.nix
    ../../modules/system.nix
  ];

  # Bootloader and Kernel Configuration
  boot = {
    # Use the latest kernel packages
    kernelPackages = pkgs.linuxPackages_latest;

    # Additional kernel modules (currently none)
    extraModulePackages = [ ];

    # Kernel modules loaded in stage 1 (initrd)
    initrd = {
      systemd.enable = true;

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

      kernelModules = [ ];

      # Custom service to warm the page cache by touching common binaries
      # (helps reduce initial I/O latency after boot)
      systemd.services.cache-preload = {
        description = "Warm page cache with common binaries";
        wantedBy = [ "initrd.target" ];
        serviceConfig = {
          ExecStart = "/bin/sh -c 'cat /nix/store/*/bin/* > /dev/null 2>&1'";
          Type = "oneshot";
        };
      };
    };

    # Kernel sysctl tunables for better performance and responsiveness
    kernel.sysctl = {
      # Start background writes earlier to avoid stutters
      "vm.dirty_background_ratio" = 5;
      # Lower threshold for foreground writes
      "vm.dirty_ratio" = 10;
      # Prefer keeping active pages in RAM
      "vm.swappiness" = 10;
      # Retain inode/dentry cache longer
      "vm.vfs_cache_pressure" = 50;
    };

    # Base kernel modules (e.g., for virtualization)
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    # Bootloader configuration (systemd-boot with EFI)
    loader = {
      efi = {
        # Prevent modification of EFI vars
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
    };

    # Additional supported filesystems (added after defaults)
    supportedFilesystems = lib.mkAfter [
      "btrfs"
      "ext4"
      "f2fs"
      "ntfs"
      "squashfs"
      "vfat"
      "xfs"
    ];

    # Temorary on RAM
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "50%";
  };

  # Filesystem Mounts
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIX-ROOT";
      fsType = "f2fs";
      options = [
        # Enable background garbage collection
        "background_gc=on"
        # Zstd compression for better performance
        "compress_algorithm=zstd:3"
        # Checksum for compressed data
        "compress_chksum"
        # Enable TRIM for SSDs
        "discard"
        # Reduce writes by not updating access times
        "noatime"
        # Lazy timestamp updates
        "lazytime"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIX-BOOT";
      fsType = "vfat";
    };

    # Volatile storage in RAM to reduce disk writes
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
        "size=30%"
        "mode=0755"
      ];
    };

    "/home/sergiu/.cache" = {
      fsType = "tmpfs";
      options = [
        "size=30%"
        "mode=0777"
      ];
    };

    "/var/cache" = {
      fsType = "tmpfs";
      options = [
        "size=10%"
        "mode=0755"
      ];
    };

    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "size=3%"
        "mode=0755"
      ];
    };

    "/var/tmp" = {
      fsType = "tmpfs";
      options = [
        "size=2%"
        "mode=1777"
      ];
    };

    "/root/.cache" = {
      fsType = "tmpfs";
      options = [
        "size=1%"
      ];
    };

    "/var/spool" = {
      fsType = "tmpfs";
      options = [
        "size=1%"
        "mode=0755"
      ];
    };

    # Edge temp folder
    "/home/sergiu/.var/app/com.microsoft.Edge/cache" = {
      fsType = "tmpfs";
      options = [
        "size=30%"
        "mode=0777"
      ];
    };

    # Jellyfin Media Player temp folder
    "/home/sergiu/.var/app/com.github.iwalton3.jellyfin-media-player/cache" = {
      fsType = "tmpfs";
      options = [
        "size=10%"
        "mode=0777"

      ];
    };
  };

  # Nix temp build dir
  environment.variables.NIX_BUILD_TMPDIR = "/tmp/nix-build";

  # Hardware and Firmware
  hardware = {
    # CPU microcode updates for both AMD and Intel
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };

    # Enable all available firmware and include linux-firmware package
    enableAllFirmware = true;
    firmware = [ pkgs.linux-firmware ];

    # Graphics and Bluetooth
    graphics.enable = true;
    bluetooth.enable = true;
  };

  # Networking
  networking = {
    hostName = "Portable-NIX";
    networkmanager.enable = true; # Use NetworkManager for easy Wi-Fi/etc.
    useDHCP = lib.mkDefault true; # Default DHCP per interface
    usePredictableInterfaceNames = false; # Prefer simple names like eth0, wlan0
  };

  # Nix Package Manager Settings
  nix = {
    gc = {
      # Disabled automatic GC
      automatic = false;
      # Would run daily if enabled
      dates = "daily";
      options = "--delete-older-than 1d";
      randomizedDelaySec = "10min";
    };

    settings = {
      # Manual optimization preferred
      auto-optimise-store = false;
      # Faster but slightly less safe
      fsync-metadata = false;
      # Follow XDG spec for config dirs
      use-xdg-base-directories = true;
    };
  };

  # Services
  services = {
    # Periodic TRIM for SSD health
    fstrim.enable = true;
    # Bluetooth manager applet
    blueman.enable = true;
    # Power profile switching
    power-profiles-daemon.enable = true;

    # Generic video drivers
    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
    ];

    # Volatile journal to minimize disk writes
    journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=50M
    '';

    # Udev rule to set BFQ scheduler for disks and SD/MMC devices
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/scheduler}="bfq"
    '';
  };

  # System Auto-Upgrade
  system.autoUpgrade = {
    # Currently disabled
    enable = false;
    allowReboot = false;
    dates = "daily";
    flake = inputs.self.outPath;
    flags = [
      "--refresh"
      "-L"
    ];
    operation = "boot";
    persistent = true;
    randomizedDelaySec = "10min";
  };

  # Power Management
  powerManagement.enable = true;

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

    services."systemd-tmpfiles-clean".enable = true;

    # Disable coredumps to save space/writes
    coredump.enable = false;
  };

  # Swap and Memory
  zramSwap = {
    # Compressed swap in RAM
    enable = true;
    memoryPercent = 50;
  };

  # Disable most documentation to save space and build time
  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # State Version
  system.stateVersion = stateVersion;
}
