{ pkgs, ... }:

let
  bravePkg = pkgs.unstable.brave; # Keep matching your installed Brave package

  mkSystemWebApp =
    {
      id,
      name,
      url,
      iconPath,
    }:
    let
      launcher = pkgs.writeShellScriptBin id ''
        exec ${bravePkg}/bin/brave \
          --ozone-platform=x11 \
          --class=${id} \
          --start-maximized \
          --app="${url}" "$@"
      '';
    in
    pkgs.symlinkJoin {
      name = id;
      paths = [
        launcher
        (pkgs.makeDesktopItem {
          name = id;
          desktopName = name;
          exec = "${launcher}/bin/${id}";
          icon = iconPath;
          categories = [
            "Network"
            "Application"
          ];
          startupWMClass = id;
        })
      ];
    };
in
{
  environment.systemPackages = [
    bravePkg

    (mkSystemWebApp {
      id = "whatsapp-pwa";
      name = "WhatsApp";
      url = "https://web.whatsapp.com";
      iconPath = "${./icons/whatsapp.svg}";
    })
    (mkSystemWebApp {
      id = "jellyfin-pwa";
      name = "Jellyfin";
      url = "https://jellyfin.ssrv.ro";
      iconPath = "${./icons/jellyfin.svg}";
    })
    (mkSystemWebApp {
      id = "homeassistant-pwa";
      name = "Home Assistant";
      url = "https://ha.ssrv.ro";
      iconPath = "${./icons/homeassistant.svg}";
    })
  ];
}
