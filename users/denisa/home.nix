{ pkgs, ... }: {
  home.username = "denisa";
  home.homeDirectory = "/home/denisa";

  home.packages = with pkgs; [


  ];

  programs.bash.enable = true;
  home.stateVersion = "25.11";
}
