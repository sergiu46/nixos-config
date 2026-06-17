{ pkgs, lib, ... }:

let
  idleTimeout = "5min";
  sleepTimeoutSeconds = 300;
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);

  # Isolate bash logic into a dedicated Nix store script
  suspendScript = pkgs.writeShellScript "suspend-to-shutdown.sh" ''
    START=$(date +%s)

    ${pkgs.util-linux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds}

    END=$(date +%s)

    if [ $((END - START)) -ge ${thresholdSeconds} ]; then
      ${pkgs.systemd}/bin/systemctl poweroff
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

  # Logind Settings
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandlePowerKey = "poweroff";
      HandleSuspendKey = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      LidSwitchIgnoreInhibited = "yes";

      IdleAction = "suspend";
      IdleActionSec = idleTimeout;
    };
  };

  # Execute the isolated script
  systemd.services.systemd-suspend.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${suspendScript}"
  ];
}
