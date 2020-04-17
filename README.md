# WIP: My [OpenWRT](https://openwrt.org/) Setup for the [PC-Engines APU2](https://www.pcengines.ch/apu2.htm)

## Download latest Image nightly build from OpenWRT Master:

[![OpenWRT-Master](https://github.com/ngerke/openwrt-apu/workflows/OpenWRT-Master/badge.svg?branch=master&event=schedule)](https://github.com/ngerke/openwrt-apu/actions?query=workflow%3AOpenWRT-Master+event%3Aschedule)
[![Last Build](https://raw.githubusercontent.com/ngerke/openwrt-apu/gh-pages/revision.svg?sanitize=true)](https://ngerke.github.io/openwrt-apu/)

[Download](https://ngerke.github.io/openwrt-apu/)

## What's this?

This is my personal Setup/Image for a OpenWRT installation on the APU2 with docker. Why? Because the apu has more than enough power to also run traefik and pihole along with OpenWRT and function as ingress node for my small home cluster.  
The image has all the APU2 + WLE600VX specific packages installed.
It's also compiled with the following settings:

```
CONFIG_DOCKER_KERNEL_OPTIONS=y
CONFIG_DOCKER_NET_ENCRYPT=y
CONFIG_DOCKER_NET_MACVLAN=y
CONFIG_DOCKER_NET_OVERLAY=y
CONFIG_DOCKER_NET_TFTP=y
CONFIG_DOCKER_RES_SHAPE=y
CONFIG_DOCKER_SECCOMP=y
CONFIG_DOCKER_STO_BTRFS=y
CONFIG_DOCKER_STO_EXT4=y
CONFIG_KERNEL_DEVMEM=y
CONFIG_TARGET_OPTIMIZATION=”-Os -pipe -march=btver2“
```

### Hardware

- PC Engines APU 2
- WLE600VX Wifi card
- 16 GB mSATA SSD (Don't use an SD card, the mSATA SSD is way faster)
- Serial to USB adapter (Setup)
- USB stick >= 4 GB (Setup)

## How to Install and Setup

### Install OpenWRT

This is only a very brief instruction on how to setup the apu for a more detailed description see the [official install guide](https://openwrt.org/toh/pcengines/apu2).

Get a serial to USB adapter and a USB stick, install [TinyCore](https://www.pcengines.ch/tinycore.htm) to it and copy the image on the stick.  
(You may also want to update your BIOS, if so follow this [guide](https://pcengines.ch/howto.htm#TinyCoreLinux) )  
Plug the stick into the apu and connect it via the USB to serial adapter with your PC, but don't power the apu on yet.  
Open a Terminal and type:
```
screen /dev/$(dmesg | grep -o -e "ttyUSB[[:digit:]]$") 115200,cs8
```

Now power on the apu, on the Terminal you should now see the apu booting TinyCore. Once booted enter the following in TinyCore

```
gzip -dc /openwrt-x86-64-combined-squashfs.img.gz | sudo dd status=progress bs=8M of=/dev/sda
```

When finished reboot and unplug the TinyCore Stick, OpenWRT is now reachable via SSH on 192.168.1.1 on the LAN interface (eth1), for convenience you may now switch to SSH.

### Setup OpenWRT

This is mainly a documentation for myself on how I set everything up.

#### Set your root password
Enter `passwd` you'll be prompted for a new password

#### Partition the rest of your volume
 Type `fdisk /dev/sda`
 Press `p` to print your partition table, it should look like this:

 ```
 Disk /dev/sda: 14.94 GiB, 16013942784 bytes, 31277232 sectors
 Disk model: SATA SSD
 Units: sectors of 1 * 512 = 512 bytes
 Sector size (logical/physical): 512 bytes / 512 bytes
 I/O size (minimum/optimal): 512 bytes / 512 bytes
 Disklabel type: dos
 Disk identifier: 0x423b062f
 Device     Boot   Start      End  Sectors  Size Id Type
 /dev/sda1  *        512    33279    32768   16M 83 Linux
 /dev/sda2         33792  1057791  1024000  500M 83 Linux
 ```

 Now press `n` to create a new partition press `Retrun` 4 times to use the  default value, this will create a partition filling up all unassinged space.  
 Press `p` again to print your partition table, it should now look like this:
 ```

 Disk /dev/sda: 14.94 GiB, 16013942784 bytes, 31277232 sectors
 Disk model: SATA SSD
 Units: sectors of 1 * 512 = 512 bytes
 Sector size (logical/physical): 512 bytes / 512 bytes
 I/O size (minimum/optimal): 512 bytes / 512 bytes
 Disklabel type: dos
 Disk identifier: 0x423b062f

 Device     Boot   Start      End  Sectors  Size Id Type
 /dev/sda1  *        512    33279    32768   16M 83 Linux
 /dev/sda2         33792  1057791  1024000  500M 83 Linux
 /dev/sda3       1058816 31277231 30218416 14.4G 83 Linux
 ```

`nano /etc/config/fstab`

```
config mount 'overlay'
        option target '/overlay'
        option device '/dev/sda3'
        option enabled '1'
```

```
mount /dev/sda3 /mnt
cp -a -f /overlay/. /mnt
umount /mnt
```

`reboot`


`dd if=/dev/zero of=/overlay/swap bs=1M count=512`

`mkswap /overlay/swap`

`nano /etc/config/fstab`

```
config swap 'swap'
        option device '/overlay/swap'
        option enabled '1'

```

`/etc/init.d/fstab boot`

`swapon -s`

```
Filename				Type		Size	Used	Priority
/overlay/swap                           file		1023996	0	-2
```

add key to $HOME/.shh/authorized_keys

test login

```
config dropbear
        option PasswordAuth 'off'
        option RootPasswordAuth 'off'
        option RootLogin 'off'
        option Port         '22'
        option Interface    'lan'
        option BannerFile   '/etc/banner'

```
