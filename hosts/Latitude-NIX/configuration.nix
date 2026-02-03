{
  lib,
  modulesPath,
  pkgs,
  userVars,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # Filesystem
    ./btrfs.nix
    # Modules
    ../../modules/auto-update.nix
    ../../modules/system.nix
    ../../modules/packages.nix
  ];

  # Networking
  networking.hostName = userVars.latitudeName; # Hostname

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
        "i915"
        "ahci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
      ];
    };
  };

  # Boot Drive
  fileSystems = {
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
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    bluetooth.enable = true; # Bluetooth
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # For Broadwell (5th gen) and newer
        intel-vaapi-driver # For older Intel CPUs
        libvdpau-va-gl # Bridges VDPAU to VAAPI
        libva-utils

      ];
    };
  };

  # Services
  services = {
    xserver.videoDrivers = [ "modesetting" ]; # Intel iGPU
  };

  # Ensure the environment knows to use these drivers
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Forces the newer intel-media-driver

  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

}
