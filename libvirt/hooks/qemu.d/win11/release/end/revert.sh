#!/bin/bash
set -x

slot_gpu="0000:03:00.0"
slot_gpu_sound="0000:03:00.1"
slot_gpu_i="0000:0e:00.0"
VIRSH_GPU_VIDEO=pci_0000_03_00_0
VIRSH_GPU_AUDIO=pci_0000_03_00_1

OBJECT="$1"
OPERATION="$2"
SUBOPERATION="$3"
EXTRA_ARG="$4"

systemctl stop libvirt-nosleep@"$OBJECT"

# # FROM https://forum.level1techs.com/t/6700xt-reset-bug/181814/19
echo 1 > /sys/bus/pci/devices/$slot_gpu/remove
echo 1 > /sys/bus/pci/devices/$slot_gpu_sound/remove
# echo 1 > /sys/bus/pci/devices/$slot_gpu_i/remove

echo "Suspending..."
rtcwake -m no -s 4 && systemctl suspend
sleep 5s
echo 1 > /sys/bus/pci/rescan
echo "Reset done"

# virsh nodedev-reattach $VIRSH_GPU_VIDEO
# virsh nodedev-reattach $VIRSH_GPU_AUDIO

modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# modprobe -r amdgpu

# driverctl unset-override $slot_gpu
# driverctl unset-override $slot_gpu_sound

modprobe amdgpu


# to amdgpu
# [ -f /sys/bus/pci/devices/$slot_gpu/driver/unbind ] && echo $slot_gpu > /sys/bus/pci/devices/$slot_gpu/driver/unbind
echo $slot_gpu > /sys/bus/pci/drivers/amdgpu/bind

# [ -f /sys/bus/pci/devices/$slot_gpu_i/driver/unbind ] && echo $slot_gpu_i > /sys/bus/pci/devices/$slot_gpu_i/driver/unbind
# echo $slot_gpu_i > /sys/bus/pci/drivers/amdgpu/bind

# [ -f /sys/bus/pci/devices/$slot_gpu_sound/driver/unbind ] && echo $slot_gpu_sound > /sys/bus/pci/devices/$slot_gpu_sound/driver/unbind
echo $slot_gpu_sound > /sys/bus/pci/drivers/snd_hda_intel/bind

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
#echo 1 > /sys/class/vtconsole/vtcon1/bind

# echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Restart Display Manager
systemctl start display-manager.service
