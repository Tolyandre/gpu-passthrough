#!/bin/bash
set -x

slot_gpu="0000:03:00.0"
slot_gpu_sound="0000:03:00.1"

#echo "1002 6719" > /sys/bus/pci/drivers/amdgpu/new_id
echo $slot_gpu > /sys/bus/pci/devices/$slot_gpu/driver/unbind
echo $slot_gpu > /sys/bus/pci/drivers/amdgpu/bind
#echo "1002 6719" > /sys/bus/pci/drivers/amdgpu/remove_id

#echo "1002 aa80" > /sys/bus/pci/drivers/snd_hda_intel/new_id
echo $slot_gpu_sound > /sys/bus/pci/devices/$slot_gpu_sound/driver/unbind
echo $slot_gpu_sound > /sys/bus/pci/drivers/snd_hda_intel/bind
#echo "1002 aa80" > /sys/bus/pci/drivers/snd_hda_intel/remove_id



# echo 1 > /sys/bus/pci/devices/$slot_gpu/remove
# echo 1 > /sys/bus/pci/devices/$slot_gpu_sound/remove
# echo 1 > /sys/bus/pci/rescan