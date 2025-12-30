{ ... }:
{
  users.users.sergiu = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    home = "/home/sergiu";
    initialHashedPassword = "$6$buw015VUknyintzF$VGdr4OGh4mwZHLcvAXkZP2i7vYDbfSbusuTMxi8qY4qVZz6m/pRhiih4tLmM2JdodHGnuug7gGu4NjBK.buhC0";

  };

  users.users.denisa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    home = "/home/denisa";
    initialHashedPassword = "$6$buw015VUknyintzF$VGdr4OGh4mwZHLcvAXkZP2i7vYDbfSbusuTMxi8qY4qVZz6m/pRhiih4tLmM2JdodHGnuug7gGu4NjBK.buhC0";
  };
}
