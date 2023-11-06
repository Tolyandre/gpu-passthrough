#!/bin/bash
set -x

# FROM https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
DEVS="0000:03:00.0 0000:03:00.1"

if [ ! -z "$(ls -A /sys/class/iommu)" ]; then
    for DEV in $DEVS; do
        echo "amdgpu" > /sys/bus/pci/devices/$DEV/driver_override
    done
fi

modprobe -i amdgpu
