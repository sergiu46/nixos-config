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
}
