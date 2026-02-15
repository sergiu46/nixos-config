{ ... }:
{
  home-manager.users.sergiu =
    { config, ... }:
    {
      # TELEGRAM: Point USB path to RAM (to save the drive)
      home.file.".local/share/TelegramDesktop/tdata/user_data".source =
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.cacheHome}/telegram-user-data";

      systemd.user.services.init-ram-cache = {
        Unit = {
          Description = "Initialize RAM cache folders and persistent links";
          After = [ "home-sergiu-.cache.mount" ];
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          Script = ''
            # Setup Telegram: Create the target folder in the RAM drive
            mkdir -p /home/sergiu/.cache/telegram-user-data

            # Setup Edge
            mkdir -p /home/sergiu/.config/cache/Microsoft
            ln -sfn /home/sergiu/.config/cache/Microsoft /home/sergiu/.cache/Microsoft
            rm -f /home/sergiu/.config/microsoft-edge/Singleton*
          '';
        };
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
