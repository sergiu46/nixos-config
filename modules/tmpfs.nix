{ ... }:
{

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  nix.settings.auto-optimise-store = true;
  nix.settings.build-dir = "/var/cache/nix-build";

  services.journald.extraConfig = "Storage=volatile";
  services.psd.enable = true;

  # systemd.tmpfiles.rules = [
  #   # Create main dirs
  #   "d /home/sergiu 0700 sergiu users - -"
  #   "d /home/sergiu/.var 0700 sergiu users - -"

  #   # Fix permissions
  #   "Z /home/sergiu/.var    0700 sergiu users  -    -"

  #   # Edge
  #   "d /tmp/edge-cache 0700 sergiu users - -"
  #   "L+ /home/sergiu/.var/app/com.microsoft.Edge/cache - - - - /tmp/edge-cache"

  #   # Jellyfin
  #   "d /tmp/jellyfin-cache 0700 sergiu users - -"
  #   "L+ /home/sergiu/.var/app/com.github.iwalton3.jellyfin-media-player/cache - - - - /tmp/jellyfin-cache"

  #   # Telegram Cache
  #   "d /tmp/telegram-cache 0700 sergiu users - -"
  #   "L+ /home/sergiu/.var/app/org.telegram.desktop/cache - - - - /tmp/telegram-cache"

  #   # Telegram Media Cache (The largest folder)
  #   "d /tmp/telegram-media-cache 0700 sergiu users - -"
  #   "L+ /home/sergiu/.var/app/org.telegram.desktop/data/TelegramDesktop/tdata/user_data/media_cache - - - - /tmp/telegram-media-cache"

  # ];

  # system.activationScripts.flatpakPermissions = {
  #   text = ''
  #     # Define a helper to reduce repetition
  #     # Usage: grant <AppID> <Path>
  #     grant() {
  #       ${pkgs.flatpak}/bin/flatpak override --user "$1" --filesystem="$2"
  #     }

  #     echo "Applying Flatpak tmpfs overrides..."

  #     # Edge
  #     grant com.microsoft.Edge /tmp/edge-cache

  #     # Jellyfin
  #     grant com.github.iwalton3.jellyfin-media-player /tmp/jellyfin-cache

  #     # Telegram (Needs both paths)
  #     grant org.telegram.desktop /tmp/telegram-cache
  #     grant org.telegram.desktop /tmp/telegram-media-cache
  #   '';
  # };

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
