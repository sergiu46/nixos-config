{ ... }:
{
  users.users.denisa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    home = "/home/denisa";
    initialHashedPassword = "$6$KBCYxtQFkuzSoCNu$V1Bax2llJJWiMVfvapePb2JyPcHQR2iyljRqqAFRHHajQ90MVgiWvobXXzU6J1CxtSwi.OxsgXf/07GzRt6kx0";
  };
  home-manager.users.denisa = import ./home.nix;

}
