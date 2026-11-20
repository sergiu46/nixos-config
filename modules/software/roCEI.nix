{ pkgs, ... }:

let
  ro-cei-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "idplugclassic-ro-cei";
    version = "4.5.0";

    src = pkgs.fetchurl {
      url = "https://hub.mai.gov.ro/cei/info/descarca-middleware?versiune=450linux";
      hash = "sha256-TQhEANzYBTX8v14rMZTplgOeyWGZJBVzsdY697/rBIQ=";
      name = "idplugclassic-${version}.deb";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      wrapGAppsHook3
    ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      pcsclite
      glib
      gtk3
      atk
      cairo
      pango
      gdk-pixbuf
      libx11
      openssl
      libjpeg8
    ];

    dontConfigure = true;
    dontBuild = true;

    # pcsclite is loaded at runtime (dlopen), so autoPatchelfHook can't see it
    gappsWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      "${pkgs.pcsclite}/lib"
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      if [ -d "usr" ]; then
        cp -r usr/* $out/
      fi

      if [ -f "$out/bin/idplugclassic/identitymanager" ]; then
        mkdir -p $out/bin
        ln -s "$out/bin/idplugclassic/identitymanager" "$out/bin/idplugclassic-manager"
      fi

      # Point the desktop entry at the wrapper and set the window class
      for f in $out/share/applications/*.desktop; do
        if [ -f "$f" ]; then
          sed -i 's|^Exec=.*|Exec=idplugclassic-manager|' "$f"
          echo "StartupWMClass=identitymanager" >> "$f"
        fi
      done

      runHook postInstall
    '';

    meta = {
      description = "Romanian Electronic ID Card (CEI) Middleware";
      homepage = "https://hub.mai.gov.ro/aplicatie-cei";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  # Smart card reader daemon required by the middleware
  services.pcscd.enable = true;

  # Install the package system-wide
  environment.systemPackages = [ ro-cei-pkg ];

  # Symlink in /usr/share to satisfy hardcoded asset paths
  systemd.tmpfiles.rules = [
    "L+ /usr/share/idplugclassic - - - - ${ro-cei-pkg}/share/idplugclassic"
  ];
}
