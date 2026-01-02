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
      "vm.dirty_background_ratio" = 5; # Start background writes earlier to avoid stutters
      "vm.dirty_ratio" = 10; # Lower threshold for foreground writes
      "vm.swappiness" = 10; # Prefer keeping active pages in RAM
      "vm.vfs_cache_pressure" = 50; # Retain inode/dentry cache longer
    };

    # Base kernel modules (e.g., for virtualization)
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    # Bootloader configuration (systemd-boot with EFI)
    loader = {
      efi = {
        canTouchEfiVariables = false; # Prevent modification of EFI vars
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 5; # Keep only the 5 most recent generations
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

    # Temporary directory settings
    tmp.tmpfsSize = "50%";
  };

  # Filesystem Mounts
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIX-ROOT";
      fsType = "f2fs";
      options = [
        "background_gc=on" # Enable background garbage collection
        "compress_algorithm=zstd:3" # Zstd compression for better performance
        "compress_chksum" # Checksum for compressed data
        "discard" # Enable TRIM for SSDs
        "noatime" # Reduce writes by not updating access times
        "lazytime" # Lazy timestamp updates
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIX-BOOT";
      fsType = "vfat";
    };

    # Volatile storage in RAM to reduce disk writes
    "/tmp".fsType = "tmpfs";
    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "mode=0755"
        "size=200M"
      ];
    };
  };

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
      automatic = false; # Disabled automatic GC
      dates = "daily"; # Would run daily if enabled
      options = "--delete-older-than 1d";
      randomizedDelaySec = "10min";
    };

    settings = {
      auto-optimise-store = false; # Manual optimization preferred
      fsync-metadata = false; # Faster but slightly less safe
      use-xdg-base-directories = true; # Follow XDG spec for config dirs
    };
  };

  # Services
  services = {
    fstrim.enable = true; # Periodic TRIM for SSD health
    blueman.enable = true; # Bluetooth manager applet
    power-profiles-daemon.enable = true; # Power profile switching

    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
    ]; # Generic drivers

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
    enable = false; # Currently disabled
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

    coredump.enable = false; # Disable coredumps to save space/writes
  };

  # Swap and Memory
  zramSwap = {
    enable = true; # Compressed swap in RAM
    memoryPercent = 25; # Use up to 25% of RAM
  };

  # Documentation
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
