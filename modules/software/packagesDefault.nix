{ pkgs, ... }:

{

  imports = [
    ./packagesLite.nix
    ./flatpak.nix
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
    geekbench
    rpi-imager
    # Stable apps
    drawing
    vlc
    libreoffice-fresh
    opensoundmeter
    audacity
    pdfarranger

    # Unstable apps
    insecure.ventoy-full-gtk
    unstable.doublecmd
    unstable.angryipscanner
    unstable.geekbench
    unstable.jellyfin-mpv-shim
  ];

}
