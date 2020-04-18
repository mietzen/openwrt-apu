#!/bin/bash
sudo chown -R $(id -u):$(id -g) .
cd openwrt
./scripts/feeds update
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages
cp ../openwrt-apu/.config-apu2-docker .config
make defconfig
make -j`nproc`
exit 0