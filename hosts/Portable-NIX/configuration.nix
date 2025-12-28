{
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sync-config.nix
    ../../common/system.nix
    ../../common/users.nix
  ];

  # Hostname
  networking.hostName = "Portable-NIX";

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

    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

    kernelParams = [
      "biosdevname=0"
      "net.ifnames=0"
    ];

    kernel.sysctl = {
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
      "vm.swappiness" = 10;
    };

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
      useTmpfs = true;
      tmpfsSize = "50%";
    };
  };

  # File Systems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "f2fs";
      options = [
        "compress_algorithm=zstd:3"
        "compress_chksum"
        "noatime"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
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

  # Hardware
  hardware = {
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };

    enableAllFirmware = true;
    firmware = [ pkgs.linux-firmware ];

    graphics.enable = true;
  };

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
    };

    settings.auto-optimise-store = true;
  };

  # Power Management
  powerManagement.cpuFreqGovernor = lib.mkDefault "balanced";

  # Services
  services = {
    fstrim.enable = true;

    journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=50M
    '';

    xserver.videoDrivers = [ "modesetting" ];
  };

  # Systemd Services
  systemd.services = {
    "systemd-journald".serviceConfig.ReadWritePaths = [ "/var/log" ];
    "systemd-tmpfiles-clean".enable = true;
  };

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 30;
  };
}
