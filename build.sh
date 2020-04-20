#!/bin/bash
sudo chown -R $(id -u):$(id -g) .
cd openwrt
git checkout $(curl -s https://downloads.openwrt.org/snapshots/targets/x86/64/version.buildinfo | cut -d'-' -f2)
rm -f feeds.conf.default
curl -s -o feeds.conf.default https://downloads.openwrt.org/snapshots/targets/x86/64/feeds.buildinfo
rm -f .config
cp ../openwrt-apu/.config-apu2-docker .config
./scripts/feeds update
./scripts/feeds install -a -p luci
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p routing
./scripts/feeds install -a -p telephony
make defconfig
make -j`nproc` download world 2>&1 | tee ../build.log
exit 0