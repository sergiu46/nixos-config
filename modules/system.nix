{ pkgs, stateVersion, ... }:

{
  # Services
  services = {
    desktopManager.gnome.enable = true; # GNOME Desktop
    displayManager.gdm.enable = true; # GDM Display Manager
    gnome.gnome-keyring.enable = true; # GNOME keyring
    fstrim.enable = true; # Enable periodic TRIM for SSDs
    blueman.enable = true; # Bluetooth manager
    power-profiles-daemon.enable = true; # Power profiles for laptops
    thermald.enable = true; # Intel Thermal management
    libinput.enable = true; # Input device management
    upower.enable = true; # Power management
    tlp.enable = false; # Disable TLP (conflicts with power-profiles-daemon)
  };

  hardware = {
    bluetooth.enable = true; # Enable Bluetooth
  };

  powerManagement.enable = true; # Enable power management

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

  # Touchpad Scrooling
  services.libinput.touchpad.accelProfile = "flat";
  services.libinput.touchpad.accelSpeed = "-1.0"; # Range is -1.0 to 1.0 (negative is slower)

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

  # Session variables for Wayland support
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "xcb"; # Force Qt apps to use X11 backend
    NIXOS_OZONE_WL = "1"; # Enable Ozone/Wayland for Chromium-based browsers
    MOZ_ENABLE_WAYLAND = "1"; # Enable Wayland for Firefox
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
