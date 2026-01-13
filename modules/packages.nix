{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Libre office
    libreoffice
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
    # Stable packages
    curl
    git
    htop
    parted
    gparted
    f2fs-tools
    tree
    wget
    vlc
    ffmpeg-full
    mkpasswd
    trayscale
    intel-gpu-tools
    libva-utils
    mpv
    # Unstable packages
    unstable.microsoft-edge
    unstable.ventoy-full-gtk
    unstable.telegram-desktop
    unstable.jellyfin-desktop
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
    ];
  };

  programs.firefox = {
    enable = true;
    preferences = {
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.skipDefaultBrowserCheckOnFirstRun" = true;
      "browser.startup.homepage" = "about:newtab";
      "browser.startup.page" = 3;
    };
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}
