# An attempt to make GPU passthrough

Here I collected some qemu configs, scripts and links to passtrough my RX 6700 XT to a virtual machine.

This is not a complete work.

# Полезные ссылки

https://unix.stackexchange.com/questions/73908/how-to-reset-cycle-power-to-a-pcie-device

Документация sysfs pci
https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-bus-pci

https://aur.archlinux.org/packages/vendor-reset-dkms-git
Перед установкой установить linuxXX-headers, где XX зависит от версии ядра.

https://github.com/joeknock90/Single-GPU-Passthrough
https://github.com/PassthroughPOST/VFIO-Tools
libvirt qemu scripts

# Полезные команды
- `lspci -vk -s 03:00`
- `inxi -G`
- `glxinfo | grep OpenGL`
- `driverctl`


# Configure GRUB & modules
- `vfio-pci.disable_idle_d3=1`
- `rd.driver.pre=vfio-pci amd_iommu=on quiet splash udev.log_priority=3 vfio-pci.ids=1002:73df,1002:ab28 vfio-pci.disable_idle_d3=1`


# Install qemu
https://www.howtoforge.com/how-to-install-kvm-qemu-on-manjaro-archlinux/
```bash
sudo pacman -S qemu virt-manager libvirt virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables libguestfs

sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd
```

# Configure VM
https://github.com/bryansteiner/gpu-passthrough-tutorial#----part-3-creating-the-vm
Make sure that on the Overview page under Firmware you select UEFI x86_64: /usr/share/edk2/x64/OVMF_CODE.secboot.fd


```xml
<features>
    ...
    <hyperv>
        <relaxed state="on"/>
        <vapic state="on"/>
        <spinlocks state="on" retries="8191"/>
        <vendor_id state="on" value="kvm hyperv"/>
    </hyperv>
    ...
</features>
```

```xml
<features>
    ...
    <hyperv>
        ...
    </hyperv>
    <kvm>
      <hidden state="on"/>
    </kvm>
    ...
</features>
```

```xml
<vcpu placement="static">12</vcpu>
<cputune>
    <vcpupin vcpu="0" cpuset="6"/>
    <vcpupin vcpu="1" cpuset="18"/>
    <vcpupin vcpu="2" cpuset="7"/>
    <vcpupin vcpu="3" cpuset="19"/>
    <vcpupin vcpu="4" cpuset="8"/>
    <vcpupin vcpu="5" cpuset="20"/>
    <vcpupin vcpu="6" cpuset="9"/>
    <vcpupin vcpu="7" cpuset="21"/>
    <vcpupin vcpu="8" cpuset="10"/>
    <vcpupin vcpu="9" cpuset="22"/>
    <vcpupin vcpu="10" cpuset="11"/>
    <vcpupin vcpu="11" cpuset="23"/>
    <emulatorpin cpuset="0-3"/>
    <iothreadpin iothread='1' cpuset='4-5,12-17'/>
</cputune>
```

```xml
<cpu mode="host-passthrough" check="none">
  <topology sockets="1" cores="6" threads="2"/>
  <cache mode='passthrough'/>
  <feature policy='require' name='topoext'/>
</cpu>
```


```xml
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x03" slot="0x00" function="0x0"/>
  </source>
  <rom file="/home/toly/Repo/Navi22.rom"/>
  <address type="pci" domain="0x0000" bus="0x06" slot="0x00" function="0x0"/>
</hostdev>
```


CPU option 2
```xml
 <vcpu placement="static" cpuset="0-5,12-17">12</vcpu>


  <cpu mode="host-passthrough" check="none" migratable="on">
    <topology sockets="1" dies="1" cores="6" threads="2"/>
    <cache mode="passthrough"/>
  </cpu>

```