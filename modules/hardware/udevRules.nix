{ ... }:

{
  services = {

    udev.extraRules = ''
      # BFQ for internal NVMe/SSD
      ACTION=="add|change", \
        KERNEL=="nvme[0-9]*|mmcblk[0-9]*", \
        ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="bfq"

      # BFQ and responsiveness tuning for any USB storage device (flash drives, USB SSDs, UASP)
      ACTION=="add|change", \
        SUBSYSTEM=="block", \
        KERNEL=="sd[a-z]", \
        SUBSYSTEMS=="usb", \
        ATTR{queue/scheduler}="bfq", \
        ATTR{queue/nr_requests}="128", \
        ATTR{queue/read_ahead_kb}="256", \
        RUN+="/bin/sh -c 'test -w /sys/block/%k/queue/iosched/low_latency && echo 1 > /sys/block/%k/queue/iosched/low_latency; test -w /sys/block/%k/queue/iosched/slice_idle && echo 0 > /sys/block/%k/queue/iosched/slice_idle; true'"

      # Ghost Mode: Hide internal drives of the host machine
      # SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';

  };
}
