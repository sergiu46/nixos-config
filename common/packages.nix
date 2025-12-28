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
    vim
    wget
    # Libre office
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    # unstable.microsoft-edge
    # unstable.telegram-desktop
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
    update.onActivation = true;

    packages = [
      "com.github.iwalton3.jellyfin-media-player"
      "com.microsoft.Edge"
      "org.telegram.desktop"
    ];
  };

  # Firefox
  programs.firefox.enable = true;
}
