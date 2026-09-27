{ ... }:

{
  boot = {
    initrd = {
      systemd.enable = true; # required by unl0kr
      verbose = false;
      unl0kr = {
        enable = true;
        settings = {
          general.animations = true;
          theme.default = "pmos-dark"; # or "pmos-light"
        };
      };

      # Input drivers for unl0kr (Keyboard, Mouse & Touchscreen)
      availableKernelModules = [
        "usbhid"
        "hid_generic"
        "hid_multitouch"
        "atkbd"
        "i8042"
        "evdev"
        "psmouse"
        "i2c_hid"
        "i2c_hid_acpi"
        "i2c_designware_platform"
        "i2c_designware_core"
      ];
    };

    # Quiet console - unl0kr's own themed screen is the visual moment that
    # matters here, not scrolling kernel/udev/systemd log text beforehand
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "intremap=on"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
