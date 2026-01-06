{ inputs, ... }:

{
  # Bootloader entry limits
  boot.loader = {
    systemd-boot.configurationLimit = 5;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
    randomizedDelaySec = "30min";
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    allowReboot = false;
    dates = "daily";
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--refresh"
      "--recreate-lock-file"

    ];
    operation = "boot";
    persistent = true;
    randomizedDelaySec = "30min";
  };

  # Persistent GC timer
  systemd.timers.nix-gc.timerConfig = {
    Persistent = true;
  };
}
