{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # --- Bootloader Support ---
  # This section ensures the USB can boot on almost any modern PC
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.initrd.systemd.enable = true;

  systemd.services."systemd-journald".serviceConfig.ReadWritePaths = [ "/var/log" ];

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
      "compress_algorithm=zstd"
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
  zramSwap.memoryPercent = 50;

  # Enables DHCP on all interfaces (portable networking)
  networking.useDHCP = lib.mkDefault true;

  # Power management for laptops
  powerManagement.cpuFreqGovernor = lib.mkDefault "balanced";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;
}
