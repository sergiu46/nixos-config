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
    brave
    #microsoft-edge
    # Unstable apps
    unstable.ventoy-full-gtk
    unstable.telegram-desktop
    unstable.jellyfin-desktop
    unstable.bitwarden-desktop
  ];

  # Brave blur fix
  nixpkgs.overlays = [
    (final: prev: {
      brave = prev.brave.override {
        commandLineArgs = "--ozone-platform=wayland --disable-features=WaylandFractionalScaleV1";
      };
    })
  ];

  programs.firefox = {
    enable = true;
    preferences = {
      # Basic Cleanups
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.skipDefaultBrowserCheckOnFirstRun" = true;

      # Core Acceleration (Safe for all modern GPUs)
      "media.ffmpeg.vaapi.enabled" = true;
      "gfx.webrender.all" = true;
      "gfx.webrender.compositor" = true;
      "media.rdd-ffmpeg.enabled" = true;

      # Modern Wayland / HiDPI Scaling Support
      "widget.wayland-dmabuf-vaapi.enabled" = true;
      "widget.wayland.fractional-scale-factor.enabled" = true;
    };
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_CRASHREPORTER_DISABLE = "1"; # Disable crash reports
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}
