{ pkgs, ... }:

let
  mkSystemWebApp =
    {
      id,
      name,
      url,
      iconPath,
    }:
    let
      launcher = pkgs.writeShellScriptBin id ''
        exec ${pkgs.brave}/bin/brave \
          --ozone-platform=x11 \
          --class=${id} \
          --user-data-dir="$HOME/.local/share/brave-webapps/${id}" \
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
    pkgs.brave

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
  ];
}
