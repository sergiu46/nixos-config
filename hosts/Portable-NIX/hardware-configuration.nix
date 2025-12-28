{
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # --- Bootloader Support ---
  # This section ensures the USB can boot on almost any modern PC
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.initrd.systemd.enable = true;

  systemd.services."systemd-journald".serviceConfig.ReadWritePaths = [ "/var/log" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  boot.kernelParams = [
    "net.ifnames=0"
    "biosdevname=0"
  ];

  systemd.services."systemd-tmpfiles-clean".enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ohci_pci"
    "uhci_hcd"
    "ahci"
    "usb_storage"
    "uas"
    "sd_mod"
    "sr_mod"
    "nvme"
    "ahci"
    "rtsx_pci"
    "mmc_block"
    "mmc_core"
    "sdhci_pci"
    "sdhci_acpi"

  ];

  # Support all common filesystems
  boot.supportedFilesystems = lib.mkForce [
    "ext4"
    "btrfs"
    "xfs"
    "vfat"
    "ntfs"
    "f2fs"
    "squashfs"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "f2fs";
    options = [
      "noatime"
      "compress_algorithm=zstd:3"
      "compress_chksum"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  fileSystems."/tmp".fsType = "tmpfs";
  fileSystems."/var/log" = {
    fsType = "tmpfs";
    options = [
      "mode=0755"
      "size=200M"
    ];
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 30;

  hardware.graphics.enable = true;

  # Enables DHCP on all interfaces (portable networking)
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  # Power management for laptops
  powerManagement.cpuFreqGovernor = lib.mkDefault "balanced";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;
}
