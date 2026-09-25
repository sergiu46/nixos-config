{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.libnotify ];

  systemd.user.services.boot-error-notify = {
    description = "Notify of failed systemd services and critical hardware/storage faults on ${config.networking.hostName}";
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

      # 2. Check for critical hardware, GPU, CPU, and filesystem faults (btrfs, ext4, f2fs, zfs)
      CRIT_PATTERN="I/O error|blk_update_request|bad sector|SMART|Machine Check|MCE|thermal|throttling|GPU.*reset|GPU.*hang|ring.*hang|f2fs|zfs|ext4|btrfs|remount-ro|read-only|corrupted"

      ERROR_COUNT=$(journalctl -k -p 3 -q --no-pager | grep -iE "$CRIT_PATTERN" | grep -c .)

      if [ "$ERROR_COUNT" -gt 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical -t 15000 \
          "Hardware / Storage Error Detected" \
          "$ERROR_COUNT critical hardware or filesystem error(s) detected in kernel logs. Run 'journalctl -k -p 3' to view."
      fi
    '';
  };
}
