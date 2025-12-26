{ ... }:
{
  users.users.sergiu = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    home = "/home/sergiu";
  };

  users.users.denisa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    home = "/home/denisa";
  };
}
