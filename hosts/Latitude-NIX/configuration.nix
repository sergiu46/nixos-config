{
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
    ../../modules/tmpfs.nix
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

}
