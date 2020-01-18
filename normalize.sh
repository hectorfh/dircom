#!/bin/sh

die() { echo '\033[0;31m'FATAL: `date`: "$*"'\033[0m'; exit 1; }

if [ $# -ne 1 ]; then
   die Usage: normalize.sh directory
fi

DIRECTORY=$1

IFS=$'\n'
for FILENAME in `find .`; do
    if [ ! -d "$FILENAME" ]; then
        EXTENSION=${FILENAME##*.}
        mv "$FILENAME" `dirname $FILENAME`/`md5 -q $FILENAME`.$EXTENSION
    fi
done

