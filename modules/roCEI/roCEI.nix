{ pkgs, ... }:

let
  ro-cei-pkg = pkgs.stdenv.mkDerivation {
    pname = "idplugclassic-ro-cei";
    version = "4.5.0";

    # Points to the local deb file stored in your config directory
    src = ./idplug-classic-4.5.0-noble-romania.deb;

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      wrapGAppsHook3 # MODIFIED
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
      libx11
      openssl
      libjpeg8
    ];

    dontConfigure = true;
    dontBuild = true;

    # MODIFIED: Arguments passed automatically to the GTK wrapper
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
        # MODIFIED: Symlink created; wrapGAppsHook3 will wrap the target binary automatically
        ln -s "$out/bin/idplugclassic/identitymanager" "$out/bin/idplugclassic-manager"
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

  # Creates a symlink in /usr/share to fix hardcoded asset paths
  systemd.tmpfiles.rules = [
    "L+ /usr/share/idplugclassic - - - - ${ro-cei-pkg}/share/idplugclassic"
  ];
}
