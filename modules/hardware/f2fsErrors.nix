{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.libnotify ];

  systemd.user.services.f2fs-mount-check = {
    description = "Notify if F2FS requires a check on ${config.networking.hostName}";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    script = ''
      # Scan current boot kernel logs for F2FS errors or failed recoveries
      if journalctl -k -b 0 | grep -iq "F2FS-fs.*error\|F2FS-fs.*recovery failed"; then
        ${pkgs.libnotify}/bin/notify-send -u critical -t 10000 \
          "Disk Check Required" \
          "Errors detected on ${config.networking.hostName}. Please run fsck.f2fs -f /dev/sdx"
      fi
    '';
  };
}
