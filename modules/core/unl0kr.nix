{ ... }:

{
  boot = {
    initrd = {
      unl0kr.enable = true;
      # Input drivers for unl0kr (Keyboard, Mouse & Touchscreen)
      availableKernelModules = [
        "usbhid"
        "hid_generic"
        "hid_multitouch"
        "evdev"
        "i2c_hid"
        "i2c_hid_acpi"
      ];
    };

    # Quiet console.
    consoleLogLevel = 0;
    kernelParams = [
      "intremap=on"
      "boot.shell_on_fail"
      "udev.log_level=3"
      "rd.systemd.show_status=false"
      "systemd.show_status=false"
    ];
  };
}
