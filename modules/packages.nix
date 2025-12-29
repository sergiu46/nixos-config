{ pkgs, ... }:

{
  # System-wide packages (Stable)
  environment.systemPackages = with pkgs; [
    curl
    git
    gparted
    htop
    parted
    gparted
    f2fs-tools
    tree
    wget
    vlc
    mkpasswd
    # Libre office
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
  ];

  # Flatpak
  services.flatpak = {
    enable = true;
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];

    packages = [
      "com.github.iwalton3.jellyfin-media-player"
      "com.microsoft.Edge"
      "org.telegram.desktop"
      "ev.deedles.Trayscale"
    ];
  };

  # Firefox
  programs.firefox.enable = true;

  #Tailscale
  services.tailscale.enable = true;
}
