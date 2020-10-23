#!/bin/bash

set -e

if test x$1 = x; then
        echo "Usage: $0 DEST_DIR"
        exit
fi
DEST=$(readlink -f $1)
shift

BUILDDIR=$(readlink -f ${BUILDDIR:=build})
SRCDIR=$(readlink -f ${SRCDIR:=llvm-project})

LLVM_DEV_DIR=$(dirname $(readlink -f $0))

echo BUILD_TYPE=${BUILD_TYPE:=Release}
echo SRCDIR=${SRCDIR}
echo BUILDDIR=${BUILDDIR}
echo DEST=${DEST}
echo JOBS=${JOBS}
JOBS=${JOBS:-j8}

read -p 'OK? (y/N): ' yn
case "${yn}" in
        [yY]) ;;
        *) echo abort; exit ;;
esac

make -f ${LLVM_DEV_DIR}/Makefile BUILD_TYPE=$BUILD_TYPE \
    DEST=$DEST SRCDIR=$SRCDIR BUILDDIR=$BUILDDIR THREAD=$JOBS all

