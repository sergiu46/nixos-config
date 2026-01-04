{ pkgs, stateVersion, ... }:

{
  # Desktop environment
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    gnome.gnome-keyring.enable = true; # GNOME keyring
  };
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-tour
    yelp
    showtime
  ];

  # Mutter experimental features (for better fractional scaling, VRR, etc.)
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer"
              "variable-refresh-rate"
              "xwayland-native-scaling"
            ];
          };
        };
      }
    ];
  };

  # Audio (PipeWire modern stack)
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = false;
    pulse.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # Locale and internationalization
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

  # Timezone and hardware clock (to match dual-boot Windows)
  time = {
    timeZone = "Europe/Bucharest";
    hardwareClockInLocalTime = true;
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "ro";
    variant = "";
  };

  # Printing and driver support
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
    ];
  };

  # Network discovery (mDNS for local services/printers)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Nix settings
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = stateVersion;
}
