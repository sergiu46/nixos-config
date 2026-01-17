{ pkgs, stateVersion, ... }:
{
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;
  programs.bash.enable = true;
  imports = [
    ../../modules/vscode.nix
  ];

  # Configure the SSH Client to use bitwarden
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      setEnv = {
        TERM = "xterm-256color";
      };
      identityAgent = "~/.bitwarden-ssh-agent.sock";
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
    # Build commands
    check = "nixos-rebuild build --flake ~/NixOS#$(hostname)";
    switch = "sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)";
    boot = "sudo nixos-rebuild boot --flake ~/NixOS#$(hostname)";

    # Install Portable
    format-portable = ''
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep part && \
      echo -n "Type the device to format (e.g. /dev/sda3): " && \
      read dev && \
      sudo umount -l "$dev" 2>/dev/null || true && \
      sudo mkfs.f2fs -f -l Portable-NIX -O extra_attr,inode_checksum,sb_checksum,compression -o 5 "$dev"
    '';
    mount-portable = ''
      sudo mount -t f2fs -o noatime,lazytime,background_gc=sync,compress_algorithm=lz4,compress_chksum,compress_mode=fs,compress_extension=*,atgc,gc_merge,flush_merge,checkpoint_merge,inline_xattr /dev/disk/by-label/Portable-NIX /mnt && \
      sudo chattr +c /mnt && \
      sudo mkdir -p /mnt/boot && \
      sudo mount /dev/disk/by-label/NIXEFI /mnt/boot
    '';
    umount-portable = ''
      sudo umount /mnt/boot && \
      sudo umount /mnt
    '';
    install-portable = "sudo nixos-install --flake ~/NixOS#Portable-NIX";
    # For all
    clean = ''
      sudo nix-collect-garbage -d && \
      nix-collect-garbage -d && \
      nix store optimise && \
      flatpak uninstall --unused -y
    '';
    update = "cd ~/NixOS && sudo nix flake update";
    # GNOME Favorite apps
    favorites = "gsettings get org.gnome.shell favorite-apps";
  };

  # QT dark theme
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  # GNOME customization
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/screensaver" = {
        lock-enabled = false;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "suspend";
        sleep-inactive-ac-timeout = 7200;
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.alphabetical-app-grid.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "microsoft-edge.desktop"
          "org.jellyfin.JellyfinDesktop.desktop"
          "org.telegram.desktop.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "bitwarden.desktop"
        ];
      };
    };
  };
}
