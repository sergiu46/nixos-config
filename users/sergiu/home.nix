{
  pkgs,
  stateVersion,
  userVars,
  ...
}:

{
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;
  programs.bash.enable = true;
  imports = [
    ../../modules/vscode.nix
  ];

  # Dark mode variables
  home.sessionVariables = {
    COLOR_SCHEME = "prefer-dark";
    ADW_DISABLE_PORTAL = "0";
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
        sleep-inactive-battery-type = "suspend";
        sleep-inactive-battery-timeout = 900;
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

  # QT dark theme
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # GTK dark theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

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
    # SYSTEM BUILD
    check = "${pkgs.time}/bin/time -f 'Duration: %E' nixos-rebuild build --flake ~/NixOS#$(hostname)";
    switch = "${pkgs.time}/bin/time -f 'Duration: %E' sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)";
    boot = "${pkgs.time}/bin/time -f 'Duration: %E' sudo nixos-rebuild boot --flake ~/NixOS#$(hostname)";
    update = "cd ~/NixOS && ${pkgs.time}/bin/time -f 'Duration: %E' sudo bash -c 'nix flake update && nixos-rebuild boot --flake .#$(hostname)'";

    clean = ''
      ${pkgs.time}/bin/time -f 'Duration: %E' sudo bash -c "
        sudo -u $(logname) nix-collect-garbage --delete-older-than 1d && \
        nix-collect-garbage --delete-older-than 1d && \
        nix store optimise && \
        /run/current-system/bin/switch-to-configuration boot && \
        command -v flatpak &> /dev/null && flatpak uninstall --unused -y || true
      "
    '';
  };

  programs.bash.initExtra = ''

    format-btrfs() {
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,LABEL | grep part
      read -p "Target device for Btrfs: " dev
      read -p "Enter Config Name (e.g., Latitude-NIX): " name
      [ -b "$dev" ] && \
      read -p "REALLY wipe $dev and label it '$name'? (y/n): " CONFIRM && \
      [ "$CONFIRM" == "y" ] && \
      sudo mkfs.btrfs -L "$name" -f "$dev" && \
      sudo mount "$dev" /mnt && \
      sudo btrfs subvolume create /mnt/@ && \
      sudo btrfs subvolume create /mnt/@home && \
      sudo btrfs subvolume create /mnt/@nix && \
      sudo umount /mnt && \
      echo "Btrfs $name initialized."
    }

    mount-btrfs() {
      read -p "Enter Config Name to mount: " name
      sudo mkdir -p /mnt && \
      sudo mount -t btrfs -o subvol=@,${userVars.btrfs.optsString} /dev/disk/by-label/"$name" /mnt && \
      sudo mkdir -p /mnt/{home,nix,boot} && \
      sudo mount -t btrfs -o subvol=@home,${userVars.btrfs.optsString} /dev/disk/by-label/"$name" /mnt/home && \
      sudo mount -t btrfs -o subvol=@nix,${userVars.btrfs.optsString} /dev/disk/by-label/"$name" /mnt/nix
      echo "Btrfs $name mounted."
    }

    format-portable() {
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,LABEL | grep -E "part|disk"
      echo ""

      read -p "Target BOOT partition (e.g., /dev/sda4): " dev_boot
      read -p "Target ROOT partition (e.g., /dev/sda3): " dev_root
      read -p "Enter Config Name (e.g., Samsung-NIX): " name
      
      local efi_name=$(echo "''${name:0:4}" | tr '[:lower:]' '[:upper:]')EFI
      local root_name="$name"

      if [ -b "$dev_boot" ] && [ -b "$dev_root" ]; then
        echo "--------------------------------------------------"
        echo "PREPARING DRIVE FOR: $name"
        echo "BOOT: $dev_boot -> FAT32 (Label: $efi_name, Flags: hidden)"
        echo "ROOT: $dev_root -> F2FS  (Label: $root_name)"
        echo "--------------------------------------------------"
        read -p "REALLY wipe these partitions? (y/n): " CONFIRM
        
        if [ "$CONFIRM" == "y" ]; then
          sudo umount -l "$dev_boot" "$dev_root" 2>/dev/null || true
          
          echo "Formatting Boot partition as FAT32..."
          sudo mkfs.fat -F 32 -n "$efi_name" "$dev_boot"
          
          local disk=$(echo "$dev_boot" | sed 's/[0-9]*$//')
          local part_num=$(echo "$dev_boot" | grep -o '[0-9]*$')
          
          # Apply the hidden flag
          sudo parted "$disk" set "$part_num" hidden on
          
          echo "Formatting Root partition as F2FS..."
          sudo mkfs.f2fs -f -l "$root_name" -O extra_attr,inode_checksum,sb_checksum,compression -o 5 "$dev_root"
          
          echo "--------------------------------------------------"
          echo "Success! You can now run: mount-portable (select $name)"
        fi
      else
        echo "Error: Partition devices not found. Check your paths."
      fi
    }

    mount-portable() {
      read -p "Enter Config Name to mount (e.g., Samsung-NIX): " name
      local efi_name=$(echo "''${name:0:4}" | tr '[:lower:]' '[:upper:]')EFI
      sudo mkdir -p /mnt
      sudo mount -t f2fs -o ${userVars.f2fs.optsString} /dev/disk/by-label/"$name" /mnt && \
      sudo chattr +c /mnt && \
      sudo mkdir -p /mnt/boot && \
      sudo mount /dev/disk/by-label/"$efi_name" /mnt/boot && {
        local dev_path=$(readlink -f /dev/disk/by-label/"$efi_name")
        local parent_disk=$(lsblk -no pkname "$dev_path")
        local part_num=$(lsblk -no PARTN "$dev_path")
        sudo parted /dev/"$parent_disk" set "$part_num" esp on
        echo "Mounted $name and $efi_name to /mnt with ESP flags enabled."
      }
    }

    umount-nixos() {
      if [ "$EUID" -ne 0 ]; then
        sudo bash -c "$(declare -f umount-nixos); umount-nixos"
        return
      fi
      if findmnt /mnt/boot > /dev/null; then
        local dev_path=$(findmnt -vno SOURCE /mnt/boot)
        local parent_disk=$(lsblk -no pkname "$dev_path")
        local part_num=$(lsblk -no PARTN "$dev_path")
        parted /dev/"$parent_disk" set "$part_num" esp off
      else
        echo "Warning: /mnt/boot not found in mount table!"
      fi
      umount /mnt/boot 2>/dev/null
      umount /mnt 2>/dev/null
    }

    install-nixos() {
      read -p "Enter host name (e.g., Samsung-NIX): " name
      sudo bash -c "
        HOME=/root /run/current-system/sw/bin/time -f 'Duration: %E' \
        nixos-install --flake /home/sergiu/NixOS#$name --no-root-passwd
        $(declare -f umount-nixos); umount-nixos
      "
    }

    gnome-reset() {
      echo "Cleaning GNOME user settings and caches..."
      dconf reset -f /
      rm -rf ~/.config/dconf/user
      rm -rf ~/.cache/gnome-shell/*
      rm -rf ~/.local/share/gnome-shell/notifications
    }

  '';
}
