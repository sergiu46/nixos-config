{ ... }:

{
  services.logind.settings = {
    Login = {
      HandleSuspendKey = "poweroff";
      HandleHibernateKey = "poweroff";
      HandleLidSwitch = "ignore";

      # Trigger shutdown after idle timeout
      IdleAction = "poweroff";
      IdleActionSec = "1800"; # Time in seconds (e.g., 1800 = 30 minutes)
    };
  };

  systemd.targets.suspend.enable = false;
  systemd.targets.sleep.enable = false;
}
