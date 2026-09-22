{ ... }:

{

  systemd.user.services.user-symlinks = {
    description = "User symlinks";
    before = [ "graphical-session-pre.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # BRAVE SETUP
      rm -f $HOME/.config/BraveSoftware/Brave-Browser/Singleton*

      # TELEGRAM SETUP
      mkdir -p $XDG_RUNTIME_DIR/telegram_cache
      mkdir -p $HOME/.local/share/TelegramDesktop/tdata
      rm -rf $HOME/.local/share/TelegramDesktop/tdata/user_data
      ln -sfn $XDG_RUNTIME_DIR/telegram_cache $HOME/.local/share/TelegramDesktop/tdata/user_data

      # GNOME SETUP
      mkdir -p $XDG_RUNTIME_DIR/gvfs-metadata
      mkdir -p $HOME/.local/share/
      rm -rf $HOME/.local/share/gvfs-metadata
      ln -sfn $XDG_RUNTIME_DIR/gvfs-metadata $HOME/.local/share/gvfs-metadata
    '';
  };

  # Use tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "80%";
  boot.tmp.cleanOnBoot = true;

  # Browser Speedup: Profile-sync-daemon
  services.psd.enable = true;

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

  # tmpfs Drives
  fileSystems = {
    # .cache RAM drive
    "/home/sergiu/.cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "size=50%"
        "mode=0700"
        "uid=1000"
      ];
    };

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
