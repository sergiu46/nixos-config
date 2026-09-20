{ pkgs, ... }:

{
  # Printing and driver support
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
    ];
  };

  # Network discovery (mDNS for local services/printers)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

}
