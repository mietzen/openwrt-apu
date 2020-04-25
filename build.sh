#!/bin/bash
sudo chown -R $(id -u):$(id -g) .
cd openwrt
./scripts/feeds update
./scripts/feeds install -a
git clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
cp ../openwrt-apu/.config-apu2-image .config
make defconfig
make -j`nproc` download world 2>&1 | tee ../build.log
exit 0