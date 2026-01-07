{ pkgs, ... }:

{
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
    unstable.microsoft-edge
    # Libre office
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    # Gnome extensions
    gnomeExtensions.system-monitor
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.forge
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
  ];

  # Flatpak
  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    update = {
      onActivation = true;
    };
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];
    packages = [
      "com.bitwarden.desktop"
      "org.telegram.desktop"
      "com.github.iwalton3.jellyfin-media-player"
    ];
  };

  # Firefox
  programs.firefox = {
    enable = true;
    preferences = {
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.skipDefaultBrowserCheckOnFirstRun" = true;
    };
  };

  #Tailscale
  # services.tailscale.enable = true;
  #"dev.deedles.Trayscale"
}
