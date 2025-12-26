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
      # DELETE the userSettings = { ... }; block from here entirely.
    };
  };

  # This tells Nix to point the VS Code config to a real file in your repo folder
  # instead of creating a read-only file in the /nix/store
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${user}/NixOS/users/sergiu/vscode-settings.json";

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    alejandra
  ];
}
