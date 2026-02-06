{
  lib,
  modulesPath,
  pkgs,
  configName,
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
    ../../modules/packagesExtra.nix
  ];

  # Networking
  networking.hostName = configName;

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
    kernelParams = [
      "initcall_parallel=1" # Faster boot
      "scsi_mod.use_blk_mq=1" # Multi-queue for storage
      "intel_pstate=active"
    ];
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
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        libva-utils
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
  };

  # Services
  services = {
    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
    ]; # Intel iGPU
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

}
