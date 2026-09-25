{ config, lib, ... }:

let
  # Filtrăm toți utilizatorii normali
  normalUsers = lib.filterAttrs (n: u: u.isNormalUser) config.users.users;

  # Generăm unități native systemd.mount pentru a evita bucla din fileSystems
  userCacheMounts = lib.mapAttrsToList (n: u: {
    what = "tmpfs";
    where = "${u.home}/.cache";
    type = "tmpfs";
    options = "size=80%,mode=0755,uid=${n},gid=${u.group}";
    wantedBy = [ "local-fs.target" ];
    before = [ "home-manager-${n}.service" ];
  }) normalUsers;
in
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
      rm -f "$HOME/.config/BraveSoftware/Brave-Browser/Singleton*"

      # TELEGRAM SETUP
      mkdir -p "$HOME/.cache/telegram_cache"
      mkdir -p "$HOME/.local/share/TelegramDesktop/tdata"
      rm -rf "$HOME/.local/share/TelegramDesktop/tdata/user_data"
      ln -sfn "$HOME/.cache/telegram_cache" "$HOME/.local/share/TelegramDesktop/tdata/user_data"

      # GNOME SETUP
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

  # User .cache mounts
  systemd.mounts = userCacheMounts;

  # Browser Speedup: Profile-sync-daemon
  services.psd.enable = true;

  # Logind settings for /run/user size
  services.logind.settings.Login = {
    RuntimeDirectorySize = "80%";
  };

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

  # tmpfs Drives (Sistem)
  fileSystems = {
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
