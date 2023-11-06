#!/bin/bash
set -x

slot_gpu="0000:03:00.0"
slot_gpu_sound="0000:03:00.1"

# echo "1" | tee -a /sys/bus/pci/devices/$slot_gpu/remove
# echo "1" | tee -a /sys/bus/pci/devices/$slot_gpu_sound/remove
# echo COMPUTER WILL GO TO SLEEP, PRESS POWER BUTTON TO RESUME
# sleep 2 
# echo -n mem > /sys/power/state
# echo "1" | tee -a /sys/bus/pci/rescan

# FROM https://forum.level1techs.com/t/6700xt-reset-bug/181814/19
echo 1 > /sys/bus/pci/devices/$slot_gpu/remove
echo 1 > /sys/bus/pci/devices/$slot_gpu_sound/remove
echo "Suspending..."
rtcwake -m no -s 4
systemctl suspend
sleep 5s
echo 1 > /sys/bus/pci/rescan   
echo "Reset done"