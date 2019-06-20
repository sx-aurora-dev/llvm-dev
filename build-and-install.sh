#!/bin/bash

set -e

if test x$1 = x; then
        echo "Usage: $0 DEST_DIR"
        exit
fi
DEST=$(readlink -f $1)
shift

BUILDDIR=$(readlink -f ${BUILDDIR:=build})
SRCDIR=$(readlink -f ${SRCDIR:=src})

LLVM_DEV_DIR=$(dirname $(readlink -f $0))

#echo LLVM_DEV_DIR=$LLVM_DEV_DIR
echo BUILD_TYPE=${BUILD_TYPE:=Release}
echo BUILDDIR=${BUILDDIR}
echo SRCDIR=${SRCDIR}
JOBS=${JOBS:-j8}

make -f ${LLVM_DEV_DIR}/Makefile BUILD_TYPE=$BUILD_TYPE \
    DEST=$DEST SRCDIR=$SRCDIR BUILDDIR=$BUILDDIR THREAD=$JOBS all

