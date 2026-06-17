{
  pkgs,
  lib,
  ...
}:

let
  # Define your custom timeouts here
  idleTimeout = "5min";
  sleepTimeoutSeconds = 3600; # 1 hour

  # Helper to calculate the rtcwake evaluation threshold
  thresholdSeconds = toString (sleepTimeoutSeconds - 10);
in
{
  # 1. Idle Timeout Shutdown
  services.logind.extraConfig = ''
    IdleAction=poweroff
    IdleActionSec=${idleTimeout}
  '';

  # 2. Sleep-to-Shutdown Timeout
  systemd.services.systemd-suspend.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bash}/bin/bash -c 'START=$(date +%s); ${pkgs.utillinux}/bin/rtcwake -m mem -s ${toString sleepTimeoutSeconds}; END=$(date +%s); if [ $((END - START)) -ge ${thresholdSeconds} ]; then ${pkgs.systemd}/bin/systemctl poweroff; fi'"
  ];
}
