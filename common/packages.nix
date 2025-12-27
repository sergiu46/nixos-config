{
  pkgs,
  ...
}:
{
  # System-wide packages (Stable)
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    tree
    htop
    gparted
    parted
    unstable.microsoft-edge
    unstable.telegram-desktop

    # Libreoffice
    libreoffice-qt
    hunspell
    hunspellDicts.ro_RO
    hunspellDicts.en_US
  ];

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  services.flatpak.packages = [
    "com.github.iwalton3.jellyfin-media-player"
  ];

  # Firefox
  programs.firefox.enable = true;

}
