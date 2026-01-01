{
  pkgs,
  lib,
  modulesPath,
  inputs,
  stateVersion,
  ...
}:

{
  imports = [
    # Universal Hardware Support
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sync-config.nix
    ../../modules/system.nix
    #../../modules/users.nix
  ];

  # Boot & Kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ ];
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
      systemd.services.cache-preload = {
        description = "Warm page cache with common binaries";
        wantedBy = [ "initrd.target" ];
        serviceConfig = {
          ExecStart = "/bin/sh -c 'cat /nix/store/*/bin/* > /dev/null 2>&1'";
          Type = "oneshot";
        };
      };
    };

    kernel.sysctl = {
      "vm.dirty_background_ratio" = 5; # Lowered to write sooner (avoid stutter)
      "vm.dirty_ratio" = 10;
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50; # Keep file metadata in RAM longer
    };

    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        configurationLimit = 5;
        enable = true;
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

    tmp = {
      tmpfsSize = "50%";
    };
  };

  # Root File Systems
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

    # Boot partition
    "/boot" = {
      device = "/dev/disk/by-label/NIX-BOOT";
      fsType = "vfat";
    };

    # RAM Logs
    "/tmp".fsType = "tmpfs";
    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "mode=0755"
        "size=200M"
      ];
    };
  };

  # Hardware & Graphics
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

  networking = {
    hostName = "Portable-NIX";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    usePredictableInterfaceNames = false;
  };

  # Nix & Store
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

  # Services & Power
  services = {
    fstrim.enable = true;
    blueman.enable = true;
    power-profiles-daemon.enable = true;

    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
    ];

    # Volatile logs to save write cycles
    journald.extraConfig = "Storage=volatile\nRuntimeMaxUse=50M";

    # Added mmcblk (SD cards) support
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/scheduler}="bfq"
    '';
  };

  # Auto-Upgrade logic
  system.autoUpgrade = {
    allowReboot = false;
    dates = "daily";
    enable = false;
    flake = inputs.self.outPath;
    flags = [
      "--refresh"
      "-L"
    ];
    operation = "boot";
    persistent = true;
    randomizedDelaySec = "10min";
  };

  # Power Management Flags
  powerManagement = {
    enable = true;
  };

  # Systemd & Mounts
  systemd.mounts = [
    {
      options = "mode=0755,size=20M";
      type = "tmpfs";
      what = "tmpfs";
      where = "/var/lib/systemd";
    }
  ];

  systemd.services = {
    "systemd-tmpfiles-clean".enable = true;
  };

  systemd.coredump.enable = false;

  # Swap & Docs
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  system.stateVersion = stateVersion;
}
