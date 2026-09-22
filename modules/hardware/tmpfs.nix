{ ... }:

{
  systemd.user.services.user-symlinks = {
    description = "User symlinks and RAM cache redirection";
    before = [ "graphical-session-pre.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "cache";
      RuntimeDirectorySize = "50%";
    };

    script = ''
      # 1. REDIRECT ENTIRE .CACHE TO RAM VIA XDG_RUNTIME_DIR
      mkdir -p "$XDG_RUNTIME_DIR/cache"
      if [ ! -L "$HOME/.cache" ]; then
        rm -rf "$HOME/.cache"
        ln -sfn "$XDG_RUNTIME_DIR/cache" "$HOME/.cache"
      fi

      # BRAVE SETUP
      rm -f "$HOME/.config/BraveSoftware/Brave-Browser/Singleton*"

      # TELEGRAM SETUP (Now automatically in RAM via .cache symlink)
      mkdir -p "$HOME/.cache/telegram_cache"
      mkdir -p "$HOME/.local/share/TelegramDesktop/tdata"
      rm -rf "$HOME/.local/share/TelegramDesktop/tdata/user_data"
      ln -sfn "$HOME/.cache/telegram_cache" "$HOME/.local/share/TelegramDesktop/tdata/user_data"

      # GNOME SETUP (Now automatically in RAM via .cache symlink)
      mkdir -p "$HOME/.cache/gvfs-metadata"
      mkdir -p "$HOME/.local/share/"
      rm -rf "$HOME/.local/share/gvfs-metadata"
      ln -sfn "$HOME/.cache/gvfs-metadata" "$HOME/.local/share/gvfs-metadata"
    '';
  };

  # Use tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "80%";
  boot.tmp.cleanOnBoot = true;

  # Browser Speedup: Profile-sync-daemon
  services.psd.enable = true;

  services.logind.extraConfig = ''
    RuntimeDirectorySize=50%
  '';

  # Log Handling: Keep logs in RAM and limited in size
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=128M
  '';

  # Nix Settings
  systemd.services.nix-daemon.environment.TMPDIR = "/var/cache/nix-build";
  nix.settings = {
    sandbox = true;
    build-dir = "/var/cache/nix-build";
  };

  # tmpfs Drives (System-level only, no user filesystems needed)
  fileSystems = {
    # Flatpak and other temporary files
    "/var/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=50%"
        "mode=1777"
      ];
    };

    # System Logs
    "/var/log" = {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "nosuid"
        "nodev"
        "size=256M"
        "mode=0755"
      ];
    };

    # Nix build directory
    "/var/cache/nix-build" = {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "nosuid"
        "nodev"
        "size=80%"
        "mode=0755"
      ];
    };

    # systemd private cache
    "/var/cache/private" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=100M"
        "mode=0700"
      ];
    };

    # CUPS print spool
    "/var/spool/cups" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=512M"
        "mode=0710"
      ];
    };

  };

}
