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
    ../../modules/packages.nix
  ];

  # Networking
  networking.hostName = "Latitude-NIX"; # Hostname

  # Nixpkgs
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Bootloader and kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    initrd = {
      kernelModules = [ ];
      availableKernelModules = [
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
      ];
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
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Hardware configuration
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true; # Bluetooth
  };

  # Power management (laptop-specific)
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "balanced"; # CPU frequency scaling
  };

  # Services
  services = {
    xserver.videoDrivers = [ "intel" ]; # Intel iGPU
    blueman.enable = true; # Bluetooth manager
    libinput.enable = true; # Touchpad support
    thermald.enable = true; # Intel thermal daemon
    tlp.enable = false; # Disabled in favor of other power tools
    upower.enable = true; # Battery monitoring
  };
}
