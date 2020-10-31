# WIP: My [OpenWRT](https://openwrt.org/) Setup for the [PC-Engines APU2](https://www.pcengines.ch/apu2.htm)

## Download latest Image nightly build from OpenWRT Master:

[![OpenWRT-Master](https://github.com/ngerke/openwrt-apu/workflows/OpenWRT%20APU2%20Image%20Builder/badge.svg?branch=master)](https://github.com/ngerke/openwrt-apu/actions?query=workflow%3A%22OpenWRT+APU2+Image+Builder%22+branch%3Amaster)
[![Last Build](https://raw.githubusercontent.com/ngerke/openwrt-apu/gh-pages/revision.svg?sanitize=true)](https://ngerke.github.io/openwrt-apu/targets/x86/64/index.html)

[Download latest build](https://ngerke.github.io/openwrt-apu/targets/x86/64/index.html)

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
- OS: 16 GB mSATA SSD (Don't use a SD card, the mSATA SSD is way faster)
- Persistent data: USB / SD-Card / S-ATA
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
 Device     Boot  Start      End  Sectors  Size Id Type
 /dev/sda1  *       512    41471    40960   20M 83 Linux
 /dev/sda2        41984   513023   471040  230M 83 Linux
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

 Device     Boot  Start      End  Sectors  Size Id Type
 /dev/sda1  *       512    41471    40960   20M 83 Linux
 /dev/sda2        41984   513023   471040  230M 83 Linux
 /dev/sda3       514048 31277231 30763184 14.7G 83 Linux

 ```

Press `w` to safe the changes

```
mkfs.ext4 /dev/sda3
```


`vi /etc/config/fstab`

```
config 'global'
	option	anon_swap	'0'
	option	anon_mount	'0'
	option	auto_swap	'1'
	option	auto_mount	'0'
	option	delay_root	'5'
	option	check_fs	'1'

config 'mount'
	option	target	'/boot'
	option	device	'/dev/sda1'
	option	enabled	'1'

config 'mount'
	option	target	'/rom'
	option	device	'/dev/sda2'
	option	enabled	'1'

config 'mount'
	option	target	'/'
	option	device	'/dev/sda3'
	option	enabled	'1'

```

```
mkdir -p /tmp/introot
mkdir -p /tmp/extroot
mount --bind / /tmp/introot
mount /dev/sda3 /tmp/extroot
tar -C /tmp/introot -cvf - . | tar -C /tmp/extroot -xf -
umount /tmp/introot
umount /tmp/extroot
```

`reboot`

#### Create a swap partition

`dd if=/dev/zero of=/swap bs=1M count=512`

`mkswap /swap`

`vi /etc/config/fstab`

```
config swap 'swap'
        option device '/swap'
        option enabled '1'

```

`/etc/init.d/fstab boot`

`swapon -s`

```
Filename				Type		Size	Used	Priority
/swap                           file		1023996	0	-2
```

#### Create a persistent data partition

#### Partition the rest of your volume

 `mkdir /data`
 Type `fdisk /dev/sdb` / `fdisk /dev/mmcblk0`
 Now press `d` to delete the old and `n` to create a new partition press `Retrun` 4 times to use the default value, this will create a partition filling up all space.
 Press `p` again to print your partition table, it should now look like this:

Press `w` to safe the changes

`mkfs.ext4 /dev/sdb1` / `mkfs.ext4 /dev/mmcblk0p1`

`vi /etc/config/fstab`

```
config 'mount'
	option	target	'/data'
	option	device	'/dev/<DEVICE>'
	option	enabled	'1'
```

`reboot`

#### Make login secure

add key to `/root/.shh/authorized_keys`

test login (!!!)

```
config dropbear
        option PasswordAuth 'off'
        option RootPasswordAuth 'off'
        option RootLogin 'off'
        option Port         '22'
        option Interface    'lan'
        option BannerFile   '/etc/banner'

```

#### Install Packages

```
opkg update
opkg install collectd-mod-disk collectd-mod-iptables collectd-mod-ping collectd-mod-uptime collectd-mod-users collectd-mod-wireless \
	curl docker-compose git-http htop luci-app-ddns luci-app-dockerman luci-app-p910nd luci-app-shadowsocks-libev luci-app-statistics \
	luci-app-vpn-policy-routing luci-app-wireguard nano shadowsocks-libev-ss-local shadowsocks-libev-ss-rules shadowsocks-libev-ss-server \
	shadowsocks-libev-ss-tunnel wireguard zsh
```
`reboot`

#### Change default shell to zsh

`nano /etc/passwd`

```
root:x:0:0:root:/root:/usr/bin/zsh
```

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Setup VPN-Client

### Setup VPN-Server

### Setup DDNS

### Setup Containers

#### Setup Swarm

#### Setup PiHole

#### Setup traefik

#### Setup Nextcloud

#### Setup Portainer

#### Setup Git-Tea

#### Setup Jenkins
