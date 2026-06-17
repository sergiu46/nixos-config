{ pkgs, lib, ... }:

let
  # Define your custom laptop timeouts here
  idleTimeout = "5min";
  sleepTimeoutSeconds = 300;

  # Helper to calculate the rtcwake evaluation threshold
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);
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

  # Sleep-to-Shutdown Engine (Fixed systemd $$ escaping)
  systemd.services.systemd-suspend.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bash}/bin/bash -c 'START=$$(date +%s); ${pkgs.util-linux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds}; END=$$(date +%s); if [ $$((END - START)) -ge ${thresholdSeconds} ]; then ${pkgs.systemd}/bin/systemctl poweroff; fi'"
  ];
}
