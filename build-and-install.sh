#!/bin/bash

set -e

echo "::::: Configuring Tools :::::"

# configure environment
function find_tool() {
  for ToolPath in "$@"; do
    local path_to_tool=$(which $ToolPath 2>/dev/null)
    if [ -x "$path_to_tool" ] ; then
       echo $path_to_tool
       return
    fi
  done
}

NINJA=$(find_tool "ninja-build" "ninja")
echo "Using ninja at ${NINJA}"

declare -a CMakeToolArray=("cmake3" "cmake")
CMAKE="cmake" #$(find_tool "cmake3" "cmake")
echo "Using cmake at ${CMAKE}"



# pick installation prefix
LLVM_DEV_DIR=$(dirname $(readlink -f $0))

DEST=$1
if test x$DEST = x; then
  DEST=${LLVM_DEV_DIR}/../install
fi

# Convert to an absolute path
DEST=$(realpath -m ${DEST})
echo "Installing LLVM for SX-Aurora to ${DEST}"

BUILDDIR=$(readlink -f ${BUILDDIR:=build})
SRCDIR=$(readlink -f ${SRCDIR:=src})

LLVM_DEV_DIR=$(dirname $(readlink -f $0))

#echo LLVM_DEV_DIR=$LLVM_DEV_DIR
echo BUILD_TYPE=${BUILD_TYPE:=Release}
echo BUILDDIR=${BUILDDIR}
echo SRCDIR=${SRCDIR}
# JOBS=${JOBS:-j8} # not required for Ninja

echo "::::: Building :::::"

make -f ${LLVM_DEV_DIR}/Makefile BUILD_TYPE=$BUILD_TYPE \
    DEST=$DEST SRCDIR=$SRCDIR BUILDDIR=$BUILDDIR THREAD=$JOBS \
    NINJA=$NINJA CMAKE=$CMAKE \
    all

echo "::::: DONE :::::"
