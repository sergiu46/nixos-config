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

        # ThinkPad Touchpad (I2C / SMBus / PS2 / RMI4)
        "psmouse"
        "i2c_designware_core"
        "i2c_designware_platform"
        "i2c_i801"
        "i2c_piix4"
        "intel_lpss_pci"
        "rmi_core"
        "rmi_smbus"
        "hid_rmi"
      ];

      # Disable standard systemd console password prompt
      systemd = {
        services."systemd-ask-password-console".enable = false;
        paths."systemd-ask-password-console".enable = false;
      };
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

    # Suppress kernel warnings via sysctl
    kernel.sysctl = {
      "kernel.printk" = "3 4 1 3";
    };
  };
}
