#!/bin/bash
sudo chown $(id -u):$(id -g) .
git clone https://git.openwrt.org/openwrt/openwrt.git openwrt
cd openwrt
./scripts/feeds update
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages
cp ../openwrt-apu/.config-apu2-docker .config
make defconfig
make -j`nproc`
exit 0