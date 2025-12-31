{
  pkgs,
  lib,
  modulesPath,
  inputs,
  config,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sync-config.nix
    ../../modules/system.nix
    ../../modules/users.nix
  ];

  # Bootloader & Kernel
  boot = {
    extraModulePackages = [ ];

    initrd = {
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
      ];
      kernelModules = [ ];
      systemd.enable = true;
    };

    kernel.sysctl = {
      "vm.dirty_background_ratio" = 10;
      "vm.dirty_ratio" = 20;
      "vm.swappiness" = 10;
    };

    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    kernelParams = [
      "biosdevname=0"
      "mq-deadline"
      "net.ifnames=0"
      "scsi_mod.use_blk_mq=1"
    ];

    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        configurationLimit = 2;
        enable = true;
      };
    };

    supportedFilesystems = lib.mkForce [
      "btrfs"
      "ext4"
      "f2fs"
      "ntfs"
      "squashfs"
      "vfat"
      "xfs"
    ];

    tmp = {
      tmpfsSize = "50%";
      useTmpfs = true;
    };
  };

  # File Systems
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
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIX-BOOT";
      fsType = "vfat";
    };

    "/tmp".fsType = "tmpfs";

    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "mode=0755"
        "size=200M"
      ];
    };
  };

  # Initrd cache warmup
  boot.initrd.systemd.services.cache-preload = {
    description = "Warm page cache with common binaries";
    wantedBy = [ "initrd.target" ];
    serviceConfig = {
      ExecStart = "/bin/sh -c 'cat /nix/store/*/bin/* > /dev/null 2>&1'";
      Type = "oneshot";
    };
  };

  # Hardware
  hardware = {
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
    enableAllFirmware = true;
    firmware = [ pkgs.linux-firmware ];
    graphics.enable = true;
    bluetooth.enable = true;
  };

  # Hostname
  networking.hostName = "Portable-NIX";

  # Networking
  networking = {
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  # Nix & Store Optimizations
  nix = {
    gc = {
      automatic = false;
      dates = "daily";
      options = "--delete-older-than 1d";
      randomizedDelaySec = "10min";
    };

    settings = {
      auto-optimise-store = false;
      fsync-metadata = false;
      use-xdg-base-directories = true;
    };
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    allowReboot = false;
    dates = "daily";
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--refresh"
      "-L"
    ];
    operation = "boot";
    persistent = true;
    randomizedDelaySec = "10min";
  };

  # Power management
  powerManagement = {
    cpuFreqGovernor = "balanced"; # CPU frequency scaling
    enable = true; # Laptop-specific power settings
  };
  # Services
  services = {
    fstrim.enable = true;
    blueman.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = true;
    xserver.videoDrivers = [ "modesetting" ];
    journald.extraConfig = "Storage=volatile\nRuntimeMaxUse=50M";
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
    '';

  };

  # Systemd Mounts
  systemd.mounts = [
    {
      options = "mode=0755,size=20M";
      type = "tmpfs";
      what = "tmpfs";
      where = "/var/lib/systemd";
    }
  ];

  # Systemd Services
  systemd.services = {
    "systemd-journald".serviceConfig.ReadWritePaths = [ "/var/log" ];
    "systemd-tmpfiles-clean".enable = true;
  };

  # Systemd Coredump
  systemd.coredump.enable = false;

  # Documentation
  documentation.man.generateCaches = false;

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
}
