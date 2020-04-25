#!/bin/bash
sudo chown -R $(id -u):$(id -g) .
cd openwrt
git checkout $(curl -s https://downloads.openwrt.org/snapshots/targets/x86/64/version.buildinfo | cut -d'-' -f2)
rm -f feeds.conf.default
curl -s -o feeds.conf.default https://downloads.openwrt.org/snapshots/targets/x86/64/feeds.buildinfo
rm -f .config
./scripts/feeds update
./scripts/feeds install -a
git clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
cp ../openwrt-apu/.config-apu2-image .config
make defconfig
make -j`nproc` download world 2>&1 | tee ../build.log
exit 0