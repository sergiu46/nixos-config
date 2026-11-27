{ ... }:

{
  services = {

    udev.extraRules = ''
      # Keep none or mq-deadline for internal NVMe/SSD
      ACTION=="add|change", \
        KERNEL=="nvme[0-9]*|mmcblk[0-9]*", \
        ATTR{queue/rotational}=="0", \
        ATTR{queue/scheduler}="none"

      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_BUS}=="usb", \
        ATTR{queue/scheduler}="bfq", ATTR{queue/read_ahead_kb}="128"

      # f2fs reads through the dm-crypt device, which has its own readahead
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="dm-[0-9]*", ENV{DM_UUID}=="CRYPT-*", \
        ATTR{queue/read_ahead_kb}="128"

      # Ghost Mode: Hide internal drives of the host machine
      # SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';

  };
}
