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

<<<<<<< HEAD
    # Office
    libreoffice-fresh
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    pdfarranger
=======
>>>>>>> refs/remotes/origin/main
    # Stable apps
    drawing
    vlc
    opensoundmeter
    audacity
<<<<<<< HEAD
=======
    pdfarranger
>>>>>>> refs/remotes/origin/main

    # Unstable apps
    insecure.ventoy-full-gtk
    unstable.angryipscanner
    unstable.geekbench
    unstable.jellyfin-mpv-shim
  ];

  fonts.packages = with pkgs; [
    corefonts # Microsoft's TrueType core fonts
    vista-fonts # Includes Calibri, Cambria, etc.
    noto-fonts # Broad Unicode & web compatibility (~70 MB)
    noto-fonts-color-emoji # Color emoji support (~10 MB)
    roboto # Popular Google UI/web font (~2 MB)
    symbola # A massive font for symbols and boxes
    freefont_ttf # Includes many standard symbols
    liberation_ttf # Excellent metric-compatible replacement for MS fonts
  ];
  fonts.fontconfig.allowBitmaps = false;

}
