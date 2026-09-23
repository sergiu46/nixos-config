{ pkgs, ... }:

{

  imports = [
    ./packagesLite.nix
    ./firefox.nix
  ];
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Utilities
    gparted
    ffmpeg-full
    intel-gpu-tools
    libva-utils
    libinput
    pciutils
    smartmontools
    kdiskmark
    # Stable apps
    drawing
    vlc
    libreoffice-fresh
    gnome-network-displays
    opensoundmeter
    # Unstable apps
    unstable.ventoy-full-gtk
    unstable.angryipscanner
  ];

}
