{
  pkgs,
  lib,
  modulesPath,
  inputs,
  config,
  stateVersion,
  ...
}:

let
  # Detect common battery paths at evaluation time so the portable image adapts.
  isLaptop = builtins.any (path: builtins.pathExists path) [
    "/sys/class/power_supply/BAT0"
    "/sys/class/power_supply/BAT1"
    "/sys/class/power_supply/BATTERY"
  ];

  # Detect Intel pstate presence for thermald gating
  hasIntelPstate = builtins.pathExists "/sys/devices/system/cpu/intel_pstate";
in
{
  imports = [
    # Universal Hardware Support
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sync-config.nix
    ../../modules/system.nix
    ../../modules/users.nix
  ];

  # Boot & Kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
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

    kernel.sysctl = lib.mkMerge [
      {
        "vm.dirty_background_ratio" = 5; # Lowered to write sooner (avoid stutter)
        "vm.dirty_ratio" = 10;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50; # Keep file metadata in RAM longer
      }
      # Laptop-friendly additions (safe defaults)
      (
        if isLaptop then
          {
            "vm.laptop_mode" = 5;
            "kernel.nmi_watchdog" = 0;
            "vm.dirty_writeback_centisecs" = 1500;
          }
        else
          { }
      )
    ];

    kernelModules = [
      "kvm-amd"
      "kvm-intel"
      "acpi_call"
    ];

    kernelParams = [
      "rootwait"
      "usbcore.autosuspend=-1"
      "biosdevname=0"
      "mq-deadline"
      "net.ifnames=0"
      "scsi_mod.use_blk_mq=1"
      "intel_pstate=active" # Modern Intel power driver
      "amd_pstate=active" # Modern AMD power driver
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
      intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
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
      automatic = false; # Manual trigger preferred on USB to avoid unexpected lag
      dates = "daily";
      options = "--delete-older-than 1d";
      randomizedDelaySec = "10min";
    };
    settings = {
      auto-optimise-store = false; # OFF to prevent USB freeze
      fsync-metadata = false;
      use-xdg-base-directories = true;
    };
  };

  # packages only for Portable
  environment.systemPackages = with pkgs; [
    power-profiles-daemon
    tlp
    # auto-cpufreq is intentionally not added to packages by default;
    # enable it only if you want it on laptops (see services below).
  ];

  # Services & Power
  services = {
    fstrim.enable = true;
    blueman.enable = true;

    # Keep power-profiles-daemon enabled for UI integration everywhere
    power-profiles-daemon.enable = true;

    # Enable TLP only on laptops (battery present). TLP is conservative and portable.
    tlp = {
      enable = isLaptop;
      # Example safe defaults; tweak if you want more aggressive battery savings.
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        # Leave disk and USB defaults to TLP's safe values; avoid aggressive defaults on unknown hardware.
      };
    };

    # Optional: auto-cpufreq for laptops only (do not enable together with TLP)
    auto-cpufreq = {
      enable = lib.mkIf isLaptop false; # keep disabled by default; set to `true` if you prefer it over TLP
    };

    # thermald: enable only when Intel pstate exists and on laptops to avoid pointless activation
    thermald.enable = lib.mkIf (isLaptop && hasIntelPstate) true;

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
    "systemd-journald".serviceConfig.ReadWritePaths = [ "/var/log" ];
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
