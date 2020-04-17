#!/bin/bash
ls -al
sudo chown $(id -u):$(id -g) .
git clone https://git.openwrt.org/openwrt/openwrt.git openwrt
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p routing
./scripts/feeds install -a -p telephony
cp ../openwrt-apu/.config-apu2-docker .config
make defconfig
make -j`nproc`
exit 0