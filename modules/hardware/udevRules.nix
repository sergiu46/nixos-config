{ ... }:

{
  services = {

    udev.extraRules = ''
      # BFQ for internal NVMe/SSD
      ACTION=="add|change", \
        KERNEL=="nvme[0-9]*|mmcblk[0-9]*", \
        ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="bfq"

      # BFQ for removable USBs (covers both usb-storage and UAS bridges)
      ACTION=="add|change", \
        SUBSYSTEM=="block", \
        KERNEL=="sd[a-z]", \
        ATTRS{removable}=="1", \
        ATTR{queue/scheduler}="bfq", \
        ATTR{queue/iosched/low_latency}="1", \
        ATTR{queue/iosched/slice_idle}="0", \
        ATTR{queue/read_ahead_kb}="512"

      # Fallback if USB enclosure reports removable==0
      ACTION=="add|change", \
        SUBSYSTEM=="block", \
        KERNEL=="sd[a-z]", \
        SUBSYSTEMS=="usb", \
        ATTR{queue/scheduler}="bfq", \
        ATTR{queue/iosched/low_latency}="1", \
        ATTR{queue/iosched/slice_idle}="0", \
        ATTR{queue/read_ahead_kb}="512"

      # Ghost Mode: Hide internal drives of the host machine
      # SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';

  };

}
