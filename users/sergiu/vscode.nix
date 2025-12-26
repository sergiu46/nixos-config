{ pkgs, ... }:

{
  # Tools used by VSCode for Nix development
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;

    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
      ];

      # This writes ~/.config/Code/User/settings.json
      userSettings = {
        "nix.serverPath" = "nixd";
        "nix.enableLanguageServer" = true;

        "nix.serverSettings" = {
          "nixd" = {
            formatting = {
              command = [ "nixfmt" ];
            };

            options = {
              nixos = {
                expr = ''(builtins.getFlake "/home/sergiu/NixOS").nixosConfigurations.myhostname.options'';
              };
              home_manager = {
                expr = ''(builtins.getFlake "/home/sergiu/NixOS").homeConfigurations.sergiu.options'';
              };
            };
          };
        };

        "editor.formatOnSave" = true;
      };
    };
  };
}
