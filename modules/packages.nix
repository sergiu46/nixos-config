{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.system-monitor
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.forge
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    # Shell
    curl
    wget
    jq
    file
    traceroute
    tree
    parted
    f2fs-tools
    mkpasswd
    # Utilities
    git
    gparted
    ffmpeg-full
    intel-gpu-tools
    libva-utils
    libinput
    # Stable apps
    vlc
    trayscale
    # Libre office
    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    # Unstable apps
    unstable.microsoft-edge
    unstable.ventoy-full-gtk
    unstable.telegram-desktop
    unstable.jellyfin-desktop
    unstable.bitwarden-desktop
    unstable.nextcloud-client
  ];

  fonts.packages = with pkgs; [
    corefonts # Microsoft's TrueType core fonts
    vista-fonts # Includes Calibri, Cambria, etc.
    google-fonts # Good for general compatibility
  ];

  # Flatpak
  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];
    # flatpak packages
    packages = [

    ];
  };

  programs.firefox = {
    enable = true;
    preferences = {
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.skipDefaultBrowserCheckOnFirstRun" = true;
      # Hardware acceleration
      "media.ffmpeg.vaapi.enabled" = true;
      "media.rdd-ffmpeg.enabled" = true;
      "media.navigator.mediadatadecoder_vpx_enabled" = true;
      "gfx.webrender.all" = true; # Force Hardware WebRender
    };
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}
