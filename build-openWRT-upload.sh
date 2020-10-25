#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

BUILD_REV=$(cat ./latest-build.rev)
BT_UL_URL="https://api.bintray.com/content/${GITHUB_ACTOR}/OpenWRT/x86_64_snapshots"
BT_PKG_API_URL="https://api.bintray.com/packages/${GITHUB_ACTOR}/OpenWRT/x86_64_snapshots"

# House keeping keep last three builds
BT_VERIONS=( $(curl -s -X GET ${BT_PKG_API_URL} | jq -r '.versions | .[]') )
if [[ " ${BT_VERIONS[@]} " =~ " ${BUILD_REV} " ]]; then
    curl -u${GITHUB_ACTOR}:${BINTRAY_API_KEY} -s -X DELETE ${BT_PKG_API_URL}/${BUILD_REV}
fi;

if [ ${#BT_VERIONS[@]} -gt 2 ]; then
    for i in ${BT_VERIONS[{2..-1}]}; do
    curl -u${GITHUB_ACTOR}:${BINTRAY_API_KEY} -s -X DELETE ${BT_PKG_API_URL}/versions/${i}
    done 
fi;
cd artifacts
zip -r artifacts.zip *
curl -s -T artifacts.zip -u${GITHUB_ACTOR}:${BINTRAY_API_KEY} ${BT_UL_URL}/${BUILD_REV}/artifacts.zip?explode=1
rm -rf artifacts.zip
exit 0