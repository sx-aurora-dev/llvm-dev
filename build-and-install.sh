#!/bin/bash

set -e

# pick installation prefix
LLVM_DEV_DIR=$(dirname $(readlink -f $0))
DEST=${LLVM_DEV_DIR}/../prefix
echo "Installing into ${DEST}"

BUILDDIR=$(readlink -f ${BUILDDIR:=build})
SRCDIR=$(readlink -f ${SRCDIR:=src})

LLVM_DEV_DIR=$(dirname $(readlink -f $0))

#echo LLVM_DEV_DIR=$LLVM_DEV_DIR
echo BUILD_TYPE=${BUILD_TYPE:=Release}
echo BUILDDIR=${BUILDDIR}
echo SRCDIR=${SRCDIR}
# JOBS=${JOBS:-j8} # not required for Ninja

make -f ${LLVM_DEV_DIR}/Makefile BUILD_TYPE=$BUILD_TYPE \
    DEST=$DEST SRCDIR=$SRCDIR BUILDDIR=$BUILDDIR THREAD=$JOBS all

