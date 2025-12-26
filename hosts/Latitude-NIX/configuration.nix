{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system.nix
    ../../common/users.nix
  ];

  networking.hostName = "Latitude-NIX";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";

  # GPU (Intel for your Latitude)
  services.xserver.videoDrivers = [ "intel" ];

  # Laptop-specific hardware settings
  powerManagement.enable = true;
  services.tlp.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable thermald for Intel laptops
  services.thermald.enable = true;

  # Enable CPU frequency scaling
  powerManagement.cpuFreqGovernor = "powersave";

  # Enable battery monitoring
  services.upower.enable = true;

  # Touchpad (optional but recommended)
  services.libinput.enable = true;

}
