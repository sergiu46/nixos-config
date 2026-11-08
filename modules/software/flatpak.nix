{ lib, ... }:

{
  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];

    overrides.settings.global = {
      Context.devices = [ "dri" ];
      Context.sockets = [
        "wayland"
        "fallback-x11"
      ];
      Environment.LIBVA_DRIVERS_PATH = lib.concatStringsSep ":" [
        "/usr/lib/x86_64-linux-gnu/dri"
        "/usr/lib/x86_64-linux-gnu/dri/intel-vaapi-driver"
        "/usr/lib/x86_64-linux-gnu/dri/nvidia-vaapi-driver"
      ];
    };
  };
}
