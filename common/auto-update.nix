{ inputs, ... }:

{
  # Bootloader entry limits
  boot.loader = {
    systemd-boot.configurationLimit = 6;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
    randomizedDelaySec = "45min";
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    allowReboot = false;
    dates = "daily";
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--refresh"
      "-L"
    ];
    operation = "boot";
    persistent = true;
    randomizedDelaySec = "45min";
  };

  # Persistent GC timer
  systemd.timers.nix-gc.timerConfig = {
    Persistent = true;
  };
}
