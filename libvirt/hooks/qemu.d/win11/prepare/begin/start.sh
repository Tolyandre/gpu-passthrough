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

systemctl start libvirt-nosleep@"$OBJECT"

# Stop display manager
# systemctl stop display-manager.service

# Unbind VTconsoles
#[ -f /sys/class/vtconsole/vtcon0/bind ] && echo 0 > /sys/class/vtconsole/vtcon0/bind
#[ -f /sys/class/vtconsole/vtcon1/bind ] && echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
# [ -f /sys/bus/platform/drivers/efi-framebuffer/unbind ] && echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
sleep 2

# to vfio-pci
modprobe -r vfio-pci
modprobe vfio
modprobe vfio-pci ids=1002:73df,1002:ab28
modprobe vfio_iommu_type1

# echo $slot_gpu > /sys/bus/pci/devices/$slot_gpu/driver/unbind
# echo $slot_gpu_sound > /sys/bus/pci/devices/$slot_gpu_sound/driver/unbind
# echo 1 > /sys/bus/pci/devices/$slot_gpu/remove
# echo 1 > /sys/bus/pci/devices/$slot_gpu_sound/remove
# # echo 1 > /sys/bus/pci/devices/$slot_gpu_i/remove

# modprobe -r amdgpu

# driverctl --nosave set-override $slot_gpu vfio-pci
# driverctl --nosave set-override $slot_gpu_sound vfio-pci

## Unbind gpu from nvidia and bind to vfio
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO


echo "Suspending..."
rtcwake -m no -s 4 && systemctl suspend
sleep 5s
#echo 1 > /sys/bus/pci/rescan
echo "Reset done"

# echo $slot_gpu > /sys/bus/pci/drivers/vfio-pci/bind
# echo $slot_gpu_sound > /sys/bus/pci/drivers/vfio-pci/bind
