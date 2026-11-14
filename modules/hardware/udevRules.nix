{ ... }:

{
  services = {

    udev.extraRules = ''
      # BFQ for internal NVMe/SSD
      ACTION=="add|change", \
        KERNEL=="nvme[0-9]*|mmcblk[0-9]*", \
        ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="bfq"

      # BFQ for removable USBs
      ACTION=="add|change", \
        SUBSYSTEM=="block", \
        KERNEL=="sd[a-z]", \
        ENV{ID_BUS}=="usb", \
        ATTR{queue/scheduler}="bfq"

      # Ghost Mode: Hide internal drives of the host machine
      # SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';

  };

}
