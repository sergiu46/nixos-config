{ config, pkgs, ... }:

let
  ro-cei-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "idplugclassic-ro-cei";
    version = "4.5.0";

    # Points to the local deb file stored in your config directory
    src = ./idplug-classic-4.5.0-noble-romania.deb;

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs; [
      pcsclite
      glibc
      gcc.cc.lib
      glib
      gtk3
      atk
      cairo
      pango
      gdk-pixbuf
      xorg.libX11
    ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      if [ -d "usr" ]; then
        cp -r usr/* $out/
      fi

      if [ -f "$out/bin/idplugclassic/identitymanager" ]; then
        mkdir -p $out/bin
        makeWrapper "$out/bin/idplugclassic/identitymanager" "$out/bin/idplugclassic-manager" \
          --prefix LD_LIBRARY_PATH : "${pkgs.pcsclite}/lib"
      fi
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
  # Enable the smart card reader service required by the application
  services.pcscd.enable = true;

  # Install the package system-wide
  environment.systemPackages = [ ro-cei-pkg ];
}
