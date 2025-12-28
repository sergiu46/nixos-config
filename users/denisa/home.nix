{ stateVersion, ... }:
{
  home.username = "denisa";
  home.homeDirectory = "/home/denisa";

  programs.bash.enable = true;
  home.stateVersion = stateVersion;
}
