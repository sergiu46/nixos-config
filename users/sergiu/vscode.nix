{ config, pkgs, ... }:

let
  user = config.home.username;
  host = "Latitude-NIX";
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;

    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
      ];

      userSettings = {
        "editor.formatOnSave" = true;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";

        "nix.serverSettings" = {
          "nixd" = {
            formatting.command = [ "nixfmt" ];

            options = {
              nixos.expr = ''(builtins.getFlake "/home/${user}/NixOS").nixosConfigurations."${host}".options'';

              home_manager.expr = ''(builtins.getFlake "/home/${user}/NixOS").homeConfigurations.${user}.options'';
            };
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    alejandra
  ];
}
