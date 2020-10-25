#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
tar -xf artifacts/targets/x86/64/openwrt-sdk-*.tar.xz 
cd openwrt-sdk-*
./scripts/feeds update
./scripts/feeds install -a
make defconfig
make -j$(($(nproc)+1)) 'IGNORE_ERRORS=n m y' BUILD_LOG=1 CONFIG_AUTOREMOVE=y CONFIG_SIGNED_PACKAGES=
cd ..
zip -r pkg-logs.zip openwrt-sdk/logs
if -f openwrt-sdk/logs/package/error.txt; then
  cat openwrt-sdk/logs/package/error.txt
fi;        
mv -f openwrt-sdk/bin artifacts
rm -rf openwrt-sdk
exit 0