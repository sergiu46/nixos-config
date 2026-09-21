{
  pkgs,
  stateVersion,
  userVars,
  ...
}:

{
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;
  programs.bash.enable = true;
  imports = [
    ../../modules/software/vscode.nix
  ];

  # autostart bitwarden
  xdg.configFile."autostart/bitwarden.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Bitwarden
    Exec=${pkgs.unstable.bitwarden-desktop}/bin/bitwarden --autostart
    Icon=bitwarden
    X-GNOME-Autostart-enabled=true
    StartupNotify=false
    Terminal=false
  '';

  # Dark mode variables
  home.sessionVariables = {
    COLOR_SCHEME = "prefer-dark";
    ADW_DISABLE_PORTAL = "0";
  };

  # GNOME customization
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        show-battery-percentage = true;
      };
      # Show week numbers in calendar
      "org/gnome/desktop/calendar" = {
        show-weekdate = true;
      };
      # Lock on screen off
      "org/gnome/desktop/screensaver" = {
        lock-enabled = true;
      };
      # Disable mouse acceleration
      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.alphabetical-app-grid.extensionUuid
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "brave-browser.desktop"
          "firefox.desktop"
          "brave-fhgggiedobllialjnmigjemojboomian-Default.desktop"
          "brave-gnkgkkpgflmdnfamhhclhoedndmefacg-Default.desktop"
          "org.telegram.desktop.desktop"
          "brave-hnpfjngllnobngcgfapefoaidbinmjnm-Default.desktop"
          "codium.desktop"
          "org.gnome.Console.desktop"
          "bitwarden.desktop"
        ];
      };
    };
  };

  # QT dark theme
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # GTK dark theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk4.theme = null;
  };

  # Configure the SSH Client to use bitwarden
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        IdentityAgent = "~/.bitwarden-ssh-agent.sock";
        # SetEnv trebuie definit ca un set de atribute, nu ca un string
        SetEnv = {
          TERM = "xterm-256color";
        };
      };
    };
  };

  # Git setup
  programs.git = {
    enable = true;
    settings = {
      user.name = "Sergiu";
      user.email = "sergiu@example.com";
    };
  };

}
