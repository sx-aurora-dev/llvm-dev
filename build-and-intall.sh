#!/bin/bash

set -e

if test x$1 = x; then
        echo "Usage: $0 DEST_DIR"
        exit
fi
DEST=$(readlink -f $1)
shift

BUILD_DIR=$(readlink -f ${BUILD_DIR:=build})
SRCDIR=$(readlink -f ${SRCDIR:=src})

LLVM_DEV_DIR=$(dirname $(readlink -f $0))

#echo LLVM_DEV_DIR=$LLVM_DEV_DIR
echo BUILD_TYPE=${BUILD_TYPE:=Release}
echo BUILD_DIR=${BUILD_DIR}
echo SRCDIR=${SRCDIR}

mkdir -p ${BUILD_DIR}

function call_make() {
        make -f ${LLVM_DEV_DIR}/Makefile \
            BUILD_TYPE=$BUILD_TYPE DEST=$DEST SRCDIR=$SRCDIR "$@"
}

function build_llvm() {
        cd ${BUILD_DIR}
        call_make cmake install
}

function build_ve_csu() {
        cd ${SRCDIR}
        call_make ve-csu
}

function build_compiler_rt() {
        cd ${BUILD_DIR}
        call_make compiler-rt
}

function build_libunwind() {
        cd ${BUILD_DIR}
        call_make libunwind
}

function build_libcxxabi() {
        cd ${BUILD_DIR}
        call_make libcxxabi
}

function build_libcxx() {
        cd ${BUILD_DIR}
        call_make libcxx
}

function build_openmp() {
        cd ${BUILD_DIR}
        call_make openmp
}

(build_llvm)
(build_ve_csu)
(build_compiler_rt)
(build_libunwind)
(build_libcxxabi)
(build_libcxx)
(build_openmp)

