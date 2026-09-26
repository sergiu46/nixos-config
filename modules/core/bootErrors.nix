{ config, pkgs, ... }:

let
  # Shared between the "boot-errors" command below and the notification
  # service, so both agree on what counts as a critical error.
  critPattern = "I/O error|blk_update_request|bad sector|SMART|Machine Check|MCE|thermal|throttling|GPU.*reset|GPU.*hang|ring.*hang|f2fs|zfs|ext4|btrfs|remount-ro|read-only|corrupted";

  bootErrors = pkgs.writeShellScriptBin "boot-errors" ''
    set -uo pipefail

    bold=$(tput bold 2>/dev/null || true)
    reset=$(tput sgr0 2>/dev/null || true)
    red=$(tput setaf 1 2>/dev/null || true)
    yellow=$(tput setaf 3 2>/dev/null || true)

    # 1. Failed systemd services
    failed=$(systemctl --failed --no-legend)
    failed_count=$(systemctl list-units --state=failed --no-legend | wc -l)

    echo "$bold$red== Failed systemd services ($failed_count) ==$reset"
    if [ "$failed_count" -gt 0 ]; then
      echo "$failed"
    else
      echo "  none"
    fi

    echo

    # 2. Critical hardware, GPU, CPU, and filesystem faults (btrfs, ext4, f2fs, zfs)
    hw_errors=$(journalctl -k -p 3 -q --no-pager | grep -iE "${critPattern}")
    hw_count=$(printf '%s\n' "$hw_errors" | grep -c .)

    echo "$bold$yellow== Hardware / storage errors ($hw_count) ==$reset"
    if [ "$hw_count" -gt 0 ]; then
      echo "$hw_errors"
    else
      echo "  none"
    fi
  '';
in
{
  environment.systemPackages = [
    pkgs.libnotify
    bootErrors
  ];

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
          "$FAILED_COUNT service(s) failed on ${config.networking.hostName}. Run 'boot-errors' for details."
      fi

      # 2. Check for critical hardware, GPU, CPU, and filesystem faults (btrfs, ext4, f2fs, zfs)
      ERROR_COUNT=$(journalctl -k -p 3 -q --no-pager | grep -iE "${critPattern}" | grep -c .)

      if [ "$ERROR_COUNT" -gt 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical -t 15000 \
          "Hardware / Storage Error Detected" \
          "$ERROR_COUNT critical hardware or filesystem error(s) detected. Run 'boot-errors' for details."
      fi
    '';
  };
}
