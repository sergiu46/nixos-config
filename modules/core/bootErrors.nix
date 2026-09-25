{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.libnotify ];

  systemd.user.services.boot-error-notify = {
    description = "Notify of failed systemd services and boot errors on ${config.networking.hostName}";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    script = ''
      # 1. Check for failed systemd services
      FAILED_COUNT=$(systemctl list-units --state=failed --no-legend | wc -l)

      if [ "$FAILED_COUNT" -gt 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical -t 15000 \
          "Boot Services Failed" \
          "$FAILED_COUNT service(s) failed on ${config.networking.hostName}. Run 'systemctl --failed' for details."
      fi

      # 2. Check for general journal errors (Priority 3 = err)
      ERROR_COUNT=$(journalctl -b -p 3 -q --no-pager | grep -v "^-- Boot" | grep -vE "dbus-broker-launch|gkr-pam: unable to locate daemon control file|No journal files were opened due to insufficient permissions" | grep -c .)

      if [ "$ERROR_COUNT" -gt 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u normal -t 10000 \
          "Boot Errors Logged" \
          "$ERROR_COUNT error lines detected in journal. Run 'journalctl -b -p 3' to view."
      fi
    '';
  };
}
