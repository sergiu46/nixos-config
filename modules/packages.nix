{ pkgs, ... }:

{
  # Insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-qt5-1.1.07"
  ];

  # System-wide packages
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
      "com.bitwarden.desktop"
      "com.microsoft.Edge"
      "org.telegram.desktop"
      "dev.deedles.Trayscale"
      "com.github.iwalton3.jellyfin-media-player"
    ];
  };

  # Firefox
  programs.firefox.enable = true;

  #Tailscale
  services.tailscale.enable = true;
}
