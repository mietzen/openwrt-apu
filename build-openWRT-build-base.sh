#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
cd openwrt
./scripts/feeds update
./scripts/feeds install -a
cp ../openwrt-apu/.config-apu2-image .config
make defconfig
make -j$(($(nproc)+1)) download world BUILD_LOG=1
zip -r ../image-logs.zip logs
cd ..
mkdir -p artifacts
mv -f openwrt/bin/* artifacts
rm -rf openwrt
exit 0