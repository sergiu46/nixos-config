{
  config,
  lib,
  pkgs,
  ...
}:

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

  # Persistent bind mount for ~/.cache/nix (tarball/fetcher/eval caches).
  # Lives on the real disk so it survives reboots, while the rest of ~/.cache stays in RAM.
  # systemd orders it after the ~/.cache tmpfs automatically (nested path).
  nixCacheMounts = lib.mapAttrsToList (n: u: {
    what = "/var/lib/nix-user-cache/${n}";
    where = "${u.home}/.cache/nix";
    type = "none";
    options = "bind";
    wantedBy = [ "local-fs.target" ];
    before = [ "home-manager-${n}.service" ];
  }) normalUsers;
in
{
  # Backing directories for the persistent ~/.cache/nix bind mounts
  systemd.tmpfiles.rules = lib.mapAttrsToList (
    n: u: "d /var/lib/nix-user-cache/${n} 0700 ${n} ${u.group} -"
  ) normalUsers;

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

  # Dynamic tmpfs mounts for Flatpak app caches with pre-mount purge
  systemd.services.flatpak-cache-tmpfs = {
    description = "Dynamic tmpfs mounts for Flatpak application caches";
    after = [
      "local-fs.target"
      "systemd-user-sessions.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: u: ''
          APP_DIR="${u.home}/.var/app"
          if [ -d "$APP_DIR" ]; then
            for app_path in "$APP_DIR"/*; do
              if [ -d "$app_path" ]; then
                CACHE_DIR="$app_path/cache"
                /run/current-system/sw/bin/mkdir -p "$CACHE_DIR"
                if ! /run/current-system/sw/bin/mountpoint -q "$CACHE_DIR"; then
                  # Purge stale files from the underlying USB layer before mounting tmpfs
                  /run/current-system/sw/bin/rm -rf "$CACHE_DIR"/* "$CACHE_DIR"/.[!.]* 2>/dev/null || true
                  /run/current-system/sw/bin/mount -t tmpfs -o size=25%,mode=0755,uid=${n},gid=${u.group} tmpfs "$CACHE_DIR"
                fi
              fi
            done
          fi
        '') normalUsers
      )}
    '';
  };

  # Use tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "80%";
  boot.tmp.cleanOnBoot = true;

  # User .cache mounts (+ persistent ~/.cache/nix on top)
  systemd.mounts = userCacheMounts ++ nixCacheMounts;

  # Browser Speedup: Profile-sync-daemon (latest from unstable)
  services.psd.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      profile-sync-daemon = final.unstable.profile-sync-daemon.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          cat > $out/share/psd/browsers/brave <<'EOF'
          DIRArr[0]="$XDG_CONFIG_HOME/BraveSoftware/Brave-Browser"
          PSNAME="brave"
          EOF
        '';
      });
    })
  ];

  environment.systemPackages = [ pkgs.profile-sync-daemon ];

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
