{ pkgs, ... }:

{
  imports = [
    ./tailscale.nix
    ./brave.nix
  ];
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
    mkpasswd
    nix-tree
    mc
    btop
    usbutils
    # Utilities
    git
    cryptsetup
    # Unstable apps
    unstable.telegram-desktop
    unstable.bitwarden-desktop
  ];

}
