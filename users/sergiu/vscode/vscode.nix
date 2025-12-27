{ config, pkgs, ... }:

let
  user = config.home.username;
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    
    # This allows VS Code to manage extensions that aren't declared in Nix
    mutableExtensionsDir = true;

    profiles.default = {
      # This ensures the extension is installed automatically
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      
      # We can also move settings here, but since you want them writable,
      # we keep the symlink below instead of 'userSettings'.
    };
  };

  # Writable symlink to your repo
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${user}/NixOS/users/${user}/vscode/vscode-settings.json";

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    alejandra
  ];
}