{ pkgs, stateVersion, ... }:
{
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;
  programs.bash.enable = true;
  imports = [
    ../../modules/vscode.nix
  ];

  home.packages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.system-monitor
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.forge
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    # Packages
    ventoy-full-gtk
  ];

  # Configure the SSH Client to use bitwarden
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      setEnv = {
        TERM = "xterm-256color";
      };
      identityAgent = "~/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
    };
  };

  # Git setup
  programs.git = {
    enable = true;
    settings = {
      user.name = "Sergiu";
      user.email = "sergiu@example.com";
    };
  };

  home.shellAliases = {
    # Latitude
    switch-latitude = "sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";
    check-latitude = "nixos-rebuild build --flake ~/NixOS#Latitude-NIX";
    boot-latitude = "sudo nixos-rebuild boot --flake ~/NixOS#Latitude-NIX";
    # Portable
    switch-portable = "sudo nixos-rebuild switch --flake ~/NixOS#Portable-NIX";
    check-portable = "nixos-rebuild build --flake ~/NixOS#Portable-NIX";
    boot-portable = "sudo nixos-rebuild boot --flake ~/NixOS#Portable-NIX";
    mount-portable = "sudo mount -t f2fs -o noatime,lazytime,background_gc=on,compress_algorithm=zstd:6,compress_chksum,compress_mode=user,atgc,gc_merge,flush_merge,checkpoint_merge,inline_xattr /dev/disk/by-label/NIX-ROOT /mnt && sudo chattr -R +c /mnt && sudo mkdir -p /mnt/boot && sudo mount /dev/disk/by-label/NIX-BOOT /mnt/boot";
    install-portable = "sudo nixos-install --flake ~/NixOS#Portable-NIX";
    # For all
    clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d && nix store gc && nix store optimise";
    update = "cd ~/NixOS && sudo nix flake update";
  };

  # GNOME customization
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        show-battery-percentage = true;
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.alphabetical-app-grid.extensionUuid
          pkgs.gnomeExtensions.clipboard-indicator.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
        ];
        favorite-apps = [
          "com.microsoft.Edge.desktop"
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "com.github.iwalton3.jellyfin-media-player.desktop"
          "org.telegram.desktop.desktop"
          "com.microsoft.Edge.flextop.msedge-hnpfjngllnobngcgfapefoaidbinmjnm-Default.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "com.bitwarden.desktop.desktop"
        ];

      };
      "org/gnome/desktop/screensaver" = {
        lock-enabled = false;
      };

    };
  };
  qt = {
    enable = true;
    platformTheme = {
      name = "adwaita";
    };
    style = {
      name = "adwaita-dark";
    };
  };
}
