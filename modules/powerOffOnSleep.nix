{
  pkgs,
  lib,
  ...
}:

let
  # Define your custom laptop timeouts here
  idleTimeout = "5min"; # Time before laptop goes to sleep
  sleepTimeoutSeconds = 300; # Time in sleep (1 hour) before shutting down

  # Helper to calculate the rtcwake evaluation threshold
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);
in
{
  # Systemd Sleep Settings - Disabling hibernation entirely
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  # Logind Settings - Idle triggers sleep, lid close triggers sleep
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandlePowerKey = "poweroff";
      HandleSuspendKey = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      LidSwitchIgnoreInhibited = "yes";

      # Laptop goes to sleep when idle instead of shutting down directly
      IdleAction = "suspend";
      IdleActionSec = idleTimeout;
    };
  };

  # Sleep-to-Shutdown Engine via RTC wake timer
  systemd.services.systemd-suspend.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bash}/bin/bash -c 'START=$(date +%s); ${pkgs.util-linux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds}; END=$(date +%s); if [ $((END - START)) -ge ${thresholdSeconds} ]; then ${pkgs.systemd}/bin/systemctl poweroff; fi'"
  ];
}
