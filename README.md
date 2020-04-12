# OpenWRT for PC-Engines Apu2

![OpenWRT-Master](https://github.com/ngerke/openwrt-apu/workflows/OpenWRT-Master/badge.svg) 

OpenWRT revision r12944-4e535d81ee
[Download](https://ngerke.github.io/openwrt-apu/)

## Setup on OpenWRT

`passwd`

`nano /etc/config/fstab`

```
config global
        option anon_swap '0'
        option anon_mount '0'
        option delay_root '5'
        option check_fs '0'
        option auto_swap '0'
        option auto_mount '0'

config mount 'boot'
        option target '/boot'
        option label 'kernel'
        option enabled '1'

config mount 'rom'
        option target '/rom'
        option label 'rootfs'
        option enabled '1'

config mount 'overlay'
        option target '/overlay'
        option label 'data'
        option enabled '1'

```

`reboot`


`dd if=/dev/zero of=/overlay/swap bs=1M count=1000`

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
