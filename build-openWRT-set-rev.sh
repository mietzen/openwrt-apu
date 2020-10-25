#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
cd openwrt
git checkout $(curl -s https://downloads.openwrt.org/snapshots/targets/x86/64/version.buildinfo | cut -d'-' -f2)
rm -f feeds.conf.default
curl -s -o feeds.conf.default https://downloads.openwrt.org/snapshots/targets/x86/64/feeds.buildinfo
rm -f .config
echo $(./scripts/getver.sh) >> ../latest-build.rev
exit 0