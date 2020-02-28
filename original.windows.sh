#!/bin/bash

vmname="windows"

if ps -ef | grep qemu-system-x86_64 | grep -q multifunction=on; then
echo "A passthrough VM is already running." &
exit 1

else

# use pulseaudio
export QEMU_AUDIO_DRV=pa
export QEMU_PA_SAMPLES=8192
export QEMU_AUDIO_TIMER_PERIOD=99
export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd

qemu-system-x86_64 \
-name $vmname,process=$vmname \
-machine type=q35,accel=kvm \
-cpu host,kvm=off \
-smp 8,sockets=1,cores=4,threads=2 \
-m 12G \
-mem-path /dev/hugepages \
-mem-prealloc \
-balloon none \
-rtc clock=host,base=localtime \
-serial none \
-parallel none \
-soundhw hda \
-nographic \
-usb \
-device usb-host,vendorid=0x46d,productid=0xc539 \
-device usb-host,vendorid=0xfeed,productid=0x0000 \
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \
-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/tmp/my_vars.fd \
-boot order=dc \
-object iothread,id=io1 \
-device virtio-blk-pci,drive=disk0,iothread=io1 \
-drive if=none,id=disk0,cache=none,format=raw,aio=threads,file=/dev/mapper/shemhazi--vg-windows \
-drive file=/home/novafacing/Downloads/win10.iso,index=1,media=cdrom \
-drive file=/home/novafacing/Downloads/virtio-win-0.1.173.iso,index=2,media=cdrom \
-netdev type=tap,id=net0,ifname=vmtap0,vhost=on \
-device virtio-net-pci,netdev=net0,mac=00:16:3e:00:13:39
#-device usb-host,vendorid=0x1a40,productid=0x0101 \

exit 0
fi
