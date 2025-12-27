{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # --- Bootloader Support ---
  # This section ensures the USB can boot on almost any modern PC
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

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
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4"; # or btrfs if you prefer
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # --- Hardware Compatibility ---
  # Enables DHCP on all interfaces (portable networking)
  networking.useDHCP = lib.mkDefault true;

  # Power management for laptops
  powerManagement.cpuFreqGovernor = lib.mkDefault "balanced";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;
}
