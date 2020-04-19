#!/bin/bash
sudo chown -R $(id -u):$(id -g) .
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p routing
./scripts/feeds install -a -p telephony
cp ../openwrt-apu/.config-apu2-docker .config
make defconfig
IGNORE_ERRORS=1
make -j`nproc` V=s download check world 2>&1 | tee ../build.log
exit 0