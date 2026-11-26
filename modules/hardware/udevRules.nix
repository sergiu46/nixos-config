{ ... }:

{
  services = {

    udev.extraRules = ''
      # Keep none or mq-deadline for internal NVMe/SSD
      ACTION=="add|change", \
        KERNEL=="nvme[0-9]*|mmcblk[0-9]*", \
        ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="none"

      # Use mq-deadline for any USB storage device to preserve full write speed while prioritizing reads
      ACTION=="add|change", \
        SUBSYSTEM=="block", \
        KERNEL=="sd[a-z]", \
        SUBSYSTEMS=="usb", \
        ATTR{queue/scheduler}="mq-deadline", \
        ATTR{queue/read_ahead_kb}="512", \
        RUN+="/bin/sh -c 'test -w /sys/block/%k/queue/iosched/read_expire && echo 100 > /sys/block/%k/queue/iosched/read_expire; true'"

      # Ghost Mode: Hide internal drives of the host machine
      # SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';

  };
}
