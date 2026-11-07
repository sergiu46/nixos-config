{ ... }:

{
  # Flatpak configuration
  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];

    overrides.settings = {
      global = {
        Context.devices = [ "dri" ];
        Context.sockets = [
          "wayland"
          "fallback-x11"
          "x11"
        ];
      };
    };
  };
}
