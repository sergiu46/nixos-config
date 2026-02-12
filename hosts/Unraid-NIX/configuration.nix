{
  modulesPath,
  pkgs,
  configName,
  ...
}:

{
  imports = [
    # Use the QEMU Guest profile for optimized VM settings
    (modulesPath + "/profiles/qemu-guest.nix")

    # Standard modules (Ensure these paths exist relative to this file)
    ../../modules/auto-update.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/sync-config.nix
    ../../modules/zramSwap.nix
    ../../modules/tmpfs.nix
  ];

  # Networking
  networking.hostName = configName;

  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    # VirtIO modules are essential for Unraid/KVM performance
    initrd = {
      availableKernelModules = [
        "virtio_pci"
        "virtio_blk"
        "virtio_scsi"
        "virtio_net"
        "virtio_balloon"
        "virtio_console"
        "ahci"
        "usbhid"
        "sr_mod"
      ];
    };
  };

  # Filesystem (Optimized for ZFS Host)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Services
  services = {
    # Allows Unraid to see IP address and manage clean shutdowns
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    # Simple video driver for the VNC/VirtIO display
    xserver.videoDrivers = [ "virtio" ];

    journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=1month
    '';
  };

  # Hardware - Minimal config for a Guest
  hardware = {
    enableRedistributableFirmware = true;
  };

  # Environment cleanup (Removed Intel-specific variables)
  environment.sessionVariables = {
    # Add any VM-specific variables here if needed
  };
}
