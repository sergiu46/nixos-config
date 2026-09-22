{ pkgs, ... }:

{
  # Purely printing-related services
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
    ];
  };

  # Optional IPP-over-USB support
  services.ipp-usb.enable = true;

}
