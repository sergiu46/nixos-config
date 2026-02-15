{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.system-monitor
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.blur-my-shell
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
    nix-tree
    # Utilities
    git
    gparted
    ffmpeg-full
    intel-gpu-tools
    libva-utils
    libinput
    pciutils
    # Stable apps
    vlc
    trayscale
    libreoffice-fresh
    angryipscanner
    # Unstable apps
    unstable.ventoy-full-gtk
    unstable.telegram-desktop
    unstable.jellyfin-desktop
    unstable.bitwarden-desktop
    unstable.microsoft-edge
  ];

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
