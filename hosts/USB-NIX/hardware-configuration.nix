{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # --- Bootloader Support ---
  # This section ensures the USB can boot on almost any modern PC
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false; # Crucial for USB: don't mess with host's EFI

  # Kernel modules for various hardware (Storage, USB 3.0, Keyboards)
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  # --- Filesystem (The "Persistence" Part) ---
  # We use Labels instead of UUIDs because UUIDs change if you re-format.
  # When you format your USB, label the partitions 'NIXOS_USB' and 'BOOT_USB'
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixroot";
    fsType = "ext4";
    options = [ "noatime" ]; # 'noatime' helps reduce wear on USB flash drives
  };

  # Note: Since ext4 doesn't have subvolumes, /home and /nix will
  # live on the same root partition unless you create separate physical partitions.

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nixboot";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ]; # Standard permissions for FAT32
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
