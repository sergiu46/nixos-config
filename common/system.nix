{ inputs, pkgs, ... }: {

  # System-wide packages (Stable)
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    tree
    htop
    unstable.microsoft-edge
    unstable.telegram-desktop

    # Libreoffice
    libreoffice-qt
    hunspell
    hunspellDicts.ro_RO
    hunspellDicts.en_US
  ];

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];

  services.flatpak.packages = [
    "com.github.iwalton3.jellyfin-media-player"
   
  ];

  # Firefox
  programs.firefox.enable = true;

  # Locale
  time.timeZone = "Europe/Bucharest";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "ro";
    variant = "";
  };


  # Enable X11
  services.xserver.enable = true;

  # GNOME Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # Printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip pkgs.gutenprint ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Automatic system upgrades using your flake
  system.autoUpgrade = {
    enable = true;
    persistent = true;                    # Run shortly after boot if the scheduled time was missed
    flake = inputs.self.outPath;          # Points to this flake (recommended when defined inside it)
    dates = "Sat,04:00";                  # Every Saturday at 04:00
    randomizedDelaySec = "45min";         # Spread load a bit
    allowReboot = false;                  # Set to true only on always-on servers
    operation = "boot";                   # Apply changes immediately (default)

    flags = [
      "--refresh"   # Equivalent to `nix flake update`: refreshes ALL inputs → latest packages & security fixes
      "-L"          # Print build logs (useful for debugging via journalctl)
    ];
  };

  # Limit bootloader entries to current + last 5 generations
  # Old generations beyond this are automatically pruned on the next rebuild
  boot.loader = {
    systemd-boot.configurationLimit = 6;  # Current + 5 previous
    # grub.configurationLimit = 6;        # Uncomment if you use GRUB instead
  };

  # Automatic garbage collection (cleans unreferenced store paths)
  nix.gc = {
    automatic = true;
    dates = "weekly";                     # Runs once per week (independent of upgrade day)
    randomizedDelaySec = "45min";
    options = "--delete-older-than 30d";  # Safety net: never delete generations newer than 30 days
  };

  # Make the GC timer persistent (catch up if the system was off)
  systemd.timers.nix-gc.timerConfig = {
    Persistent = true;
  };


# # Use gpg-agent for SSH (replaces ssh-agent, avoids graphical freeze)
#   programs.gnupg.agent = {
#     enable = true;
#     enableSSHSupport = true;     # Crucial: enables SSH key handling
#     pinentryPackage = pkgs.pinentry-curses;  # Terminal prompt (safe, no GUI freeze)
#     # pinentryPackage = pkgs.pinentry-gnome3;  # Uncomment if you prefer GNOME tray prompt
#   };

#   # Optional: Disable the old ssh-agent to avoid conflicts
#   programs.ssh.startAgent = false;



}
