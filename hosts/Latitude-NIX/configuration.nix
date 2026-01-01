{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/auto-update.nix
    ../../modules/system.nix
    ../../modules/users.nix
  ];

  # Hostname
  networking.hostName = "Latitude-NIX";

  # Bootloader and EFI
  boot = {
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  # File systems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/33a9284e-70df-4f5c-b74f-36bc473b4850";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4804-E951";
      fsType = "vfat";
      options = [
        "dmask=0077"
        "fmask=0077"
      ];
    };
  };

  # Hardware
  hardware = {
    bluetooth.enable = true; # Bluetooth
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Nixpkgs platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Power management
  powerManagement = {
    cpuFreqGovernor = "balanced"; # CPU frequency scaling
    enable = true; # Laptop-specific power settings
  };

  # Services
  services = {
    blueman.enable = true; # Bluetooth manager
    libinput.enable = true; # Touchpad support
    thermald.enable = true; # Intel thermald
    tlp.enable = false; # Disable TLP
    upower.enable = true; # Battery monitoring
    xserver.videoDrivers = [ "intel" ]; # Intel GPU
  };

  # ZRAM swap
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
}
