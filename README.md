# openwrt-apu


## Setup on OpenWRT

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

config swap 'swap'
        option device '/overlay/swap'
        option enabled '1'

```
