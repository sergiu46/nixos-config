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
    mkpasswd
    trayscale
    # Unstable packages
    unstable.microsoft-edge
    unstable.ventoy-full-gtk
    unstable.telegram-desktop

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
      "org.jellyfin.JellyfinDesktop"
    ];
  };

  # Firefox
  programs.firefox = {
    enable = true;
    preferences = {
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.skipDefaultBrowserCheckOnFirstRun" = true;
      "browser.startup.homepage" = "about:newtab";

      # Enable hardware acceleration
      "media.hardware-video-decoding.force-enabled" = true;
      "media.ffmpeg.vaapi.enabled" = true;
      "widget.dmabuf.force-enabled" = true; # Essential for Wayland
      "gfx.webrender.all" = true; # Force GPU compositing

      # Custom Toolbar Layout: Back, Forward, Reload, Home, URL bar, Account, Extensions, Menu
      "browser.uiCustomization.state" =
        "{\"placements\":{\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"urlbar-container\",\"fxa-toolbar-menu-button\",\"unified-extensions-button\",\"PanelUI-menu-button\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"currentVersion\":20}";
    };
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}
