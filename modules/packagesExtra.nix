{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.forge
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.blur-my-shell
    # Libre office
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    # Unstable packages
    unstable.nextcloud-client
  ];

  # Nextcloud Client autostart (only applies when this file is imported)
  xdg.configFile."autostart/nextcloud.desktop".text = ''
    [Desktop Entry]
    Name=Nextcloud
    Exec=${pkgs.nextcloud-client}/bin/nextcloud --background
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';

  fonts.packages = with pkgs; [
    corefonts # Microsoft's TrueType core fonts
    vista-fonts # Includes Calibri, Cambria, etc.
    google-fonts # Good for general compatibility
    symbola # A massive font for symbols and boxes
    freefont_ttf # Includes many standard symbols
    liberation_ttf # Excellent metric-compatible replacement for MS fonts
  ];
  fonts.fontconfig.allowBitmaps = false;

}
