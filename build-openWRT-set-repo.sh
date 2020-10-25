#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

BT_DL_URL="https://dl.bintray.com/${GITHUB_ACTOR}/OpenWRT"
GH_PAGES_URL="https://${GITHUB_ACTOR}.github.io/${GITHUB_REPOSITORY}/${BUILD_REV}"

cp ./openwrt-apu/latest-master.html.in ./latest-master.html
sed -i -e 's#%URL%#'${GH_PAGES_URL}'/targets/x86/64#g' ./latest-master.html
echo 'CONFIG_VERSION_REPO="'${BT_DL_URL}'"' >> ./openwrt-apu/.config-apu2-image
echo '' >> ./openwrt-apu/.config-apu2-image
exit 0