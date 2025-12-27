{

  lib,
  ...
}:

{
  imports = [
    ../../common/system.nix
    ../../common/users.nix
    # add any other modules you want portable
  ];

  # Broad hardware support
  # boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # USB-friendly bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Make booting more forgiving
  boot.kernelParams = [
    "boot.shell_on_fail"
    "nohibernate"
  ];

  # Hostname
  networking.hostName = "portable";

  # Network: DHCP everywhere
  networking.useDHCP = lib.mkDefault true;

  # Filesystems: let hardware decide
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4"; # or btrfs if you prefer
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  # Avoid hardware-specific services
  services.fwupd.enable = false;
  #hardware.bluetooth.enable = lib.mkDefault false;
  hardware.opengl.enable = true;

  # Optional: auto-mount external drives
  services.udisks2.enable = true;

  # Optional: make it feel like a live system
  system.stateVersion = "25.11";
}
