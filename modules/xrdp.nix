{ ... }:

{
  # Enable the xrdp service
  services.xrdp.enable = true;

  # Automatically open port 3389 in the firewall
  services.xrdp.openFirewall = true;

  # Set GNOME as the default window manager
  services.xrdp.defaultWindowManager = "gnome-session";
}
