{
  pkgs,
  lib,
  ...
}:

let
  sleepTimeoutSeconds = 7200; # 2h
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);

  # Isolate bash logic into a dedicated Nix store script
  suspendScript = pkgs.writeShellScript "suspend-to-shutdown.sh" ''
    START=$(date +%s)

    # Added -u to force UTC mode and protect the hardware clock from timezone corruption
    ${pkgs.util-linux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds} -u

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
