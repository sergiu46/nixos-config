{
  lib,
  modulesPath,
  pkgs,
  configName,
  userVars,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/auto-update.nix
    ../../modules/system.nix
    ../../modules/zramSwap.nix
    ../../modules/packages.nix
    ../../modules/packagesExtra.nix
    ../../modules/flatpak.nix
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
      "intel_pstate=active" # Keeps the CPU responsive
      "i915.enable_guc=2" # Authenticates HuC for smooth video
      "i915.enable_fbc=1" # Saves battery and reduces heat
      "i915.enable_psr=0" # DISABLING this prevents "hiccups" on Skylake
      "mem_sleep_default=deep" # Deep sleep
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
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4804-E951";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/${userVars.btrfs.label}";
    fsType = "btrfs";
    options = [ "subvol=@" ] ++ userVars.btrfs.optsList;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/${userVars.btrfs.label}";
    fsType = "btrfs";
    options = [ "subvol=@home" ] ++ userVars.btrfs.optsList;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/${userVars.btrfs.label}";
    fsType = "btrfs";
    options = [ "subvol=@nix" ] ++ userVars.btrfs.optsList;
    neededForBoot = true;
  };

  # Swap & Resume
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  boot.resumeDevice = "/dev/disk/by-label/swap";

  # Systemd Sleep Settings
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3600
    AllowSuspendThenHibernate=yes
  '';

  # The "Catch-All" Alias: Forces all suspends to use the hybrid logic
  systemd.targets.suspend.enable = false;
  systemd.targets.suspend-then-hibernate.aliases = [ "suspend.target" ];

  # Logind Settings
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandlePowerKey = "suspend";
      HandleSuspendKey = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      # Overrides Desktop Environment "inhibitors"
      LidSwitchIgnoreInhibited = "yes";
    };
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
    ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

}
