{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.system-monitor
    gnomeExtensions.alphabetical-app-grid
    # Shell
    curl
    wget
    jq
    file
    traceroute
    tree
    parted
    gptfdisk
    f2fs-tools
    e2fsprogs
    util-linux
    mkpasswd
    nix-tree
    # Utilities
    git
    # Stable apps
    trayscale
    brave
    # Unstable apps
    unstable.telegram-desktop
    unstable.bitwarden-desktop
  ];

  # Brave options
  nixpkgs.overlays = [
    (final: prev: {
      brave = prev.brave.override {
        commandLineArgs = [
          "--restore-last-session"
          "--hide-crash-restore-bubble"
          "--ozone-platform=wayland"
          "--disable-features=WaylandFractionalScaleV1"
          "--disk-cache-dir=/tmp/brave-cache"
          "--disable-gpu-shader-disk-cache"
        ];
      };
    })
  ];

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}
