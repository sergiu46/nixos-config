{
  pkgs,
  lib,
  ...
}:

let
  sleepTimeoutSeconds = 10800; # 3h
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);

  # Isolate bash logic into a dedicated Nix store script
  suspendScript = pkgs.writeShellScript "suspend-to-shutdown.sh" ''
    START=$(date +%s)

    # Changed to -l to perfectly match your hardwareClockInLocalTime = true setting
    ${pkgs.util-linux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds} -l

    END=$(date +%s)

    if [ $((END - START)) -ge ${thresholdSeconds} ]; then
      # Gracefully terminate all user sessions to close all open apps
      for session in $(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}'); do
        ${pkgs.systemd}/bin/loginctl terminate-session "$session"
      done

      # Wait up to 15 seconds for sessions to fully close
      for i in {1..15}; do
        if [ -z "$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend)" ]; then
          break
        fi
        sleep 1
      done

      # Queue the poweroff asynchronously to bypass systemd state locks
      ${pkgs.systemd}/bin/systemd-run --on-active=2s ${pkgs.systemd}/bin/systemctl poweroff
    fi
  '';
in
{
  # Systemd Sleep Settings
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  # Execute the isolated script
  systemd.services.systemd-suspend.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${suspendScript}"
  ];
}
