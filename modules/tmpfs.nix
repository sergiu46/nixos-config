{ ... }:
{
  systemd.services.user-symlinks = {
    description = "User symlinks";
    after = [
      "home-sergiu-.cache.mount"
      "local-fs.target"
    ];
    requires = [ "home-sergiu-.cache.mount" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      # EDGE SETUP
      mkdir -p /home/sergiu/.config/cache/Microsoft
      ln -sfn /home/sergiu/.config/cache/Microsoft /home/sergiu/.cache/Microsoft
      rm -f /home/sergiu/.config/microsoft-edge/Singleton*

      # TELEGRAM SETUP
      mkdir -p /home/sergiu/.cache/telegram_cache
      mkdir -p /home/sergiu/.local/share/TelegramDesktop/tdata
      ln -sfn /home/sergiu/.cache/telegram_cache /home/sergiu/.local/share/TelegramDesktop/tdata/user_data

      # GNOME SETUP
      mkdir -p /home/sergiu/.cache/gvfs-metadata
      mkdir -p /home/sergiu/.cache/gnome-bits
      mkdir -p /home/sergiu/.local/share/

      rm -f /home/sergiu/.local/share/gvfs-metadata
      ln -sfn /home/sergiu/.cache/gvfs-metadata /home/sergiu/.local/share/gvfs-metadata

      rm -f /home/sergiu/.local/share/recently-used.xbel
      touch /home/sergiu/.cache/gnome-bits/recently-used.xbel
      ln -sfn /home/sergiu/.cache/gnome-bits/recently-used.xbel /home/sergiu/.local/share/recently-used.xbel

    '';

    serviceConfig = {
      Type = "oneshot";
      User = "sergiu";
      Group = "users";
    };
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
    max-jobs = 1;
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
