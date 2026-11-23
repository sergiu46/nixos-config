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
    parted
    gptfdisk
    f2fs-tools
    e2fsprogs
    exfatprogs
    mkpasswd
    nix-tree
    mc
    # Utilities
    git
    cryptsetup
    # Unstable apps
    unstable.telegram-desktop
    unstable.bitwarden-desktop
  ];

}
