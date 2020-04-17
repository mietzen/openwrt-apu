#!/bin/bash
ls -al
cd openwrt
sudo chown $(id -u):$(id -g) .
./scripts/feeds update -a
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p routing
./scripts/feeds install -a -p telephony
cp ../openwrt-apu/.config-apu2-docker .config
make defconfig
make -j`nproc`
exit 0