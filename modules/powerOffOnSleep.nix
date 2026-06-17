{
  pkgs,
  lib,
  ...
}:

let
  sleepTimeoutSeconds = 7200; # 2h
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);

  suspendScript = pkgs.writeShellScript "suspend-to-shutdown.sh" ''
    START=$(date +%s)

    ${pkgs.util-linux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds}

    END=$(date +%s)

    if [ $((END - START)) -ge ${thresholdSeconds} ]; then
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
