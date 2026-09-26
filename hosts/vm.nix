{
  modulesPath,
  pkgs,
  configName,
  lib,
  ...
}:

{
  imports = [
    # Use the QEMU Guest profile for optimized VM settings
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Networking (Minimal VM Configuration)
  networking = {
    hostName = configName;
    useDHCP = lib.mkDefault true;
    usePredictableInterfaceNames = true; # Standard interface naming for VMs
  };

  # --- Bootloader and Kernel ---
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

  # --- Filesystem (Optimized for ZFS Host) ---
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

  # --- Hardware - Minimal config for a Guest ---
  hardware = {
    enableRedistributableFirmware = true;
  };

  # --- Services ---
  services = {
    # Logind Settings
    logind.settings = {
      Login = {
        IdleAction = "poweroff";
        IdleActionSec = "2h";
      };
    };

    # Allows Unraid to see IP address and manage clean shutdowns
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    # Simple video driver for the VNC/VirtIO display
    xserver.videoDrivers = [ "virtio" ];
  };

  # --- Environment ---
  environment = {
    gnome.excludePackages = with pkgs; [
      geary
      gnome-tour
      yelp
      epiphany
      gnome-calendar
      gnome-contacts
      gnome-maps
      gnome-music
      showtime
      snapshot # Camera
      simple-scan # Document Scanner
      totem # Video/Audio Player
      gnome-weather # Weather
      gnome-characters
      gnome-clocks
      gnome-font-viewer
      gnome-connections
      baobab
    ];

    # Environment cleanup (Removed Intel-specific variables)
    sessionVariables = {
      # Add any VM-specific variables here if needed
    };
  };

  # --- Misc ---
  documentation = {
    enable = false;
    nixos.enable = false;
  };
}
