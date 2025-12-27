{ config, pkgs, ... }:

let
  user = config.home.username;
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };
  };

  # This tells Nix to point the VS Code config to a real file in your repo folder
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${user}/NixOS/${user}/vscode/vscode-settings.json";

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    alejandra
  ];
}
