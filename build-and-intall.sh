#! /bin/sh

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

export DEST
export SRCDIR
export BUILD_TYPE

mkdir -p ${BUILD_DIR}

function build_llvm() {
        cd ${BUILD_DIR}
        make -f ${LLVM_DEV_DIR}/Makefile cmake install
}

function build_ve_csu() {
        cd ${SRCDIR}
        make -f ${LLVM_DEV_DIR}/Makefile ve-csu
}

function build_compiler_rt() {
        cd ${BUILD_DIR}
        make -f ${LLVM_DEV_DIR}/Makefile compiler-rt
}

function build_libunwind() {
        cd ${BUILD_DIR}
        make -f ${LLVM_DEV_DIR}/Makefile libunwind
}

function build_libcxxabi() {
        cd ${BUILD_DIR}
        make -f ${LLVM_DEV_DIR}/Makefile libcxxabi
}

function build_libcxx() {
        cd ${BUILD_DIR}
        make -f ${LLVM_DEV_DIR}/Makefile libcxx
}

function build_openmp() {
        cd ${BUILD_DIR}
        make -f ${LLVM_DEV_DIR}/Makefile openmp
}

(build_llvm)
(build_ve_csu)
(build_compiler_rt)
(build_libunwind)
(build_libcxxabi)
(build_libcxx)
(build_openmp)

