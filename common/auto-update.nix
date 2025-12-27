{
  inputs,
  ...
}:
{

  # Automatic system upgrades using your flake
  system.autoUpgrade = {
    enable = true;
    persistent = true; # Run shortly after boot if the scheduled time was missed
    flake = inputs.self.outPath; # Points to this flake (recommended when defined inside it)
    dates = "daily"; # Every Saturday at 04:00
    randomizedDelaySec = "45min"; # Spread load a bit
    allowReboot = false; # Set to true only on always-on servers
    operation = "boot"; # Apply changes immediately (default)

    flags = [
      "--refresh" # Equivalent to `nix flake update`: refreshes ALL inputs → latest packages & security fixes
      "-L" # Print build logs (useful for debugging via journalctl)
    ];
  };

  # Limit bootloader entries to current + last 5 generations
  # Old generations beyond this are automatically pruned on the next rebuild
  boot.loader = {
    systemd-boot.configurationLimit = 6; # Current + 5 previous
    # grub.configurationLimit = 6;        # Uncomment if you use GRUB instead
  };

  # Automatic garbage collection (cleans unreferenced store paths)
  nix.gc = {
    automatic = true;
    dates = "daily"; # Runs once per week (independent of upgrade day)
    randomizedDelaySec = "45min";
    options = "--delete-older-than 14d"; # Safety net: never delete generations newer than 30 days
  };

  # Make the GC timer persistent (catch up if the system was off)
  systemd.timers.nix-gc.timerConfig = {
    Persistent = true;
  };

}