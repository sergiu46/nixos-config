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
    update = "cd ~/NixOS && sudo nix flake update && boot";

    # Install Portable
    format-portable = ''
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep part && \
      echo -n "Type the device to format (e.g. /dev/sda3): " && \
      read dev && \
      sudo umount -l "$dev" 2>/dev/null || true && \
      sudo mkfs.f2fs -f -l Portable-NIX -O extra_attr,inode_checksum,sb_checksum,compression -o 5 "$dev"
    '';
    mount-portable = ''
      sudo mkdir -p /mnts && \
      sudo mount -t f2fs -o noatime,lazytime,compress_algorithm=zstd:1,compress_chksum,compress_mode=fs,compress_extension=*,atgc,gc_merge,flush_merge,discard,checkpoint_merge,active_logs=2,reserve_root=16384,inline_xattr,inline_data,inline_dentry /dev/disk/by-label/Portable-NIX /mnt && \
      sudo chattr +c /mnt && \
      sudo mkdir -p /mnt/boot && \
      sudo mount /dev/disk/by-label/NIXEFI /mnt/boot
    '';
    umount-portable = ''
      sudo umount /mnt/boot && \
      sudo umount /mnt
    '';
    install-portable = "echo 'Start: ' $(date +%T); sudo nixos-install --flake ~/NixOS#Portable-NIX; echo 'Finish: ' $(date +%T)";
    # For all
    clean = ''
      sudo nix-collect-garbage -d && \
      nix-collect-garbage -d && \
      nix store optimise && \
      flatpak uninstall --unused -y && \
      boot
    '';
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
          "microsoft-edge.desktop"
          "firefox.desktop"
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
