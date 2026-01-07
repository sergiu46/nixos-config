{

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  nix.settings.auto-optimise-store = true;
  nix.settings.build-dir = "/var/cache/nix-build";

  services.journald.extraConfig = "Storage=volatile";
  services.psd.enable = true;

  systemd.tmpfiles.rules = [
    "d /home/sergiu 0700 sergiu users - -"
    "d /home/sergiu/.var 0700 sergiu users - -"
    "d /home/sergiu/.local 0700 sergiu users - -"

    # Edge
    "d /tmp/edge-cache 0700 sergiu users - -"
    "L+ /home/sergiu/.var/app/com.microsoft.Edge/cache - - - - /tmp/edge-cache"

    # Jellyfin
    "d /tmp/jellyfin-cache 0700 sergiu users - -"
    "L+ /home/sergiu/.var/app/com.github.iwalton3.jellyfin-media-player/cache - - - - /tmp/jellyfin-cache"

    # Telegram Cache
    "d /tmp/telegram-cache 0700 sergiu users - -"
    "L+ /home/sergiu/.var/app/org.telegram.desktop/cache - - - - /tmp/telegram-cache"

    # Telegram Media Cache (The largest folder)
    "d /tmp/telegram-media-cache 0700 sergiu users - -"
    "L+ /home/sergiu/.var/app/org.telegram.desktop/data/TelegramDesktop/tdata/user_data/media_cache - - - - /tmp/telegram-media-cache"

    # Clean up partial Flatpak downloads older than 1 day
    "q /var/lib/flatpak/repo/tmp - - - 1d"
    "q /home/sergiu/.local/share/flatpak/repo/tmp - - - 1d"
  ];

  fileSystems = {
    "/home/sergiu/.cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "relatime"
        "size=50%"
        "mode=1777"
      ];
    };
    "/var/cache/nix-build" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=50%"
        "mode=0755"
      ];
    };
  };

}
