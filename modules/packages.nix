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
    # Stable apps
    vlc
    trayscale
    libreoffice
    # Unstable apps
    unstable.ventoy-full-gtk
    unstable.telegram-desktop
    unstable.jellyfin-desktop
    unstable.bitwarden-desktop
    (unstable.microsoft-edge.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer,WaylandFractionalScaleV1"
        "--disable-features=Vulkan" # Fixes the Wayland startup crash seen in your report
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
      ];
    })
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
