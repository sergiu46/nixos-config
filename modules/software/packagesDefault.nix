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
    intel-gpu-tools
    libva-utils
    libinput
    pciutils
    smartmontools
    kdiskmark

    #Gparted
    gparted
    parted
    gptfdisk
    f2fs-tools
    e2fsprogs
    exfatprogs
    dosfstools
    mtools
    btrfs-progs
    ntfs3g
    xfsprogs
    xfsdump
    gpart

    # Office
    libreoffice-fresh
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    pdfarranger
    # Stable apps
    drawing
    vlc
    opensoundmeter
    audacity

    # Unstable apps
    insecure.ventoy-full-gtk
    unstable.angryipscanner
    unstable.geekbench
    unstable.jellyfin-mpv-shim
  ];

  fonts.packages = with pkgs; [
    corefonts # Arial, Times New Roman, Courier New, Verdana
    vista-fonts # Calibri, Cambria, Consolas
    liberation_ttf # Metric-compatible fallback for Arial/Times/Courier
    noto-fonts # Broad Unicode coverage, incl. Romanian diacritics
    noto-fonts-color-emoji # Color emoji
    roboto # Popular Google UI/web font
  ];
  fonts.fontconfig.allowBitmaps = false;

}
