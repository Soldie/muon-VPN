#!/usr/bin/env bash

set -e


if [ -f Makefile ]; then
    make distclean
fi
autoreconf -if
export CC=/usr/lib/clang/ccc-analyzer
./configure --enable-debug

rm -rf .lint
scan-build -o .lint -analyze-headers --use-cc=clang make
cd .lint/
DIR=$(ls)
if [[ ${DIR} ]]; then
    mv ${DIR}/* ./
    rmdir ${DIR}
fi
cd ../

if [ -f .lint/index.html ]; then
    BUG=$(cat .lint/index.html | grep 'All Bugs' | tr '><' '\n' | grep '[0-9]')
else
    echo 'No warning found.' > .lint/index.html
    BUG=0
fi
if [ ${BUG} -lt 3 ]; then
    COLOR=brightgreen
elif [ ${BUG} -lt 6 ]; then
    COLOR=yellow
else
    COLOR=red
fi
if [ ${BUG} -lt 1 ]; then
    BUG="${BUG}%20warning"
else
    BUG="${BUG}%20warnings"
fi
curl -s -o .lint.svg "https://a.pxx.io/badge/badge/lint-${BUG}-${COLOR}.svg"

make distclean
