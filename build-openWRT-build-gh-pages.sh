#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

GH_PAGES_BRANCH="gh-pages"
GH_PAGES_REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
BT_DL_URL="https://dl.bintray.com/${GITHUB_ACTOR}/OpenWRT"

git clone ${GH_PAGES_REPO} --single-branch --branch=${GH_PAGES_BRANCH} ${GH_PAGES_BRANCH}
cd ${GH_PAGES_BRANCH}
rm -rf ./*
mv -f ../artifacts/* .

find . -type d -exec sh -c 'cd $0 && tree -H '.' -L 1 --noreport --charset utf-8 > "./0_index.html"' {} \;
find . -name '*.html' -exec sed -i -e 's#<a href=".">.</a><br>#<a href="../0_index.html">..</a><br>#g' {} \;
find . -name '*.html' -exec sed -i -e 's#/">#/0_index.html">#g' {} \;
sed -i -e 's#<a href="../0_index.html">..</a><br>#<a href="./0_index.html">.</a><br>#g' ./0_index.html
find . -name '*.html' -exec sed -i '/0_index.html<\/a><br>/d' {} \;
find . -type d -exec sh -c 'cd $0 && mv 0_index.html index.html' {} \;
find . -name '*.html' -exec sed -i -e 's/0_index.html/index.html/g' {} \;

INDEXED_FILES=( $(find . -not -name 'index.html' -type f -not -path '*/\.*' -not -path '.' -exec sh -c "echo {} | sed 's/^.\{2\}//'" \;) )
for i in "${INDEXED_FILES[@]}"; do
  REL_PATH=$(dirname ${i})
  FILE=$(basename ${i})
  sed -i -e 's#<a href="./'"${FILE}"'">'"${FILE}"'</a><br>#<a href="'"${BT_DL_URL}"'/'"${REL_PATH}"'/'"${FILE}"'">'"${FILE}"'</a><br>#g' ${REL_PATH}/index.html
done

find . -not -name 'index.html' -type f -not -path '*/\.*' -exec rm -f {} \;
cp ../latest-master.html .
cp ../latest-build.rev .
curl -s -X POST "https://img.shields.io/badge/Revision-$(cat ./latest-build.rev | sed 's/-/_/g')-blue" > ./revision.svg

git add .
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action Bot"

if [ "$GITHUB_EVENT_NAME" = "schedule" ]; then
  git commit -q -m "nightly image build"
else
  git commit -q -m "integration image build"
fi
if [ "$GITHUB_EVENT_NAME" != "pull_request" ]; then
  #git push -f "${GH_PAGES_REPO}" HEAD:${GH_PAGES_BRANCH}
fi

exit 0