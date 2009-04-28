#!/bin/sh
# Repackage upstream source to exclude non-distributable files
# should be called as "repack sh --upstream-source <ver> <downloaded file>
# (for example, via uscan)

set -e
set -u

VER="$2"
FILE="$3"
DVER="${VER}+dfsg"
PKG=`dpkg-parsechangelog|grep ^Source:|sed 's/^Source: //'`

printf "\nRepackaging $FILE\n"

DIR=`mktemp -d ./tmpRepackXXXXXX`
trap "rm -rf $DIR" QUIT INT EXIT

tar xzf $FILE -C $DIR

REPACK=`basename $FILE`

UP_DIR=`ls -1 $DIR`

(
    set -e
    set -u

    cd $DIR

    rm -vr $UP_DIR/inc/src/ $UP_DIR/inc/bin/patch.exe

    REPACK_DIR="$PKG-$VER.orig"
    mv $UP_DIR $REPACK_DIR
    tar -c $REPACK_DIR | gzip -n -9 > $REPACK
)

mv $DIR/$REPACK $FILE

echo "*** $FILE repackaged"

prename --verbose --force "s/$VER/$DVER/" $FILE
