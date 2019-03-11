THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
# LLVM_DEV_DIR requires to use an abosolute path
LLVM_DEV_DIR = $(abspath $(dir ${THIS_MAKEFILE_PATH}))

# Retrieve all sources from this repo's parent
REPO = $(dir $(shell cd ${LLVM_DEV_DIR} && git config remote.origin.url))
BRANCH = develop
BUILD_TYPE = Release
BUILD_TARGET = "VE;X86"
TARGET = ve-linux
OMPARCH = ve

# DEST, SRCDIR, BUILDDIR and others requires to use an abosolute path
DEST = ${LLVM_DEV_DIR}/install
SRCDIR = ${LLVM_DEV_DIR}
LLVM_SRCDIR = ${LLVM_DEV_DIR}/llvm              # these are not modifiable
VECSU_SRCDIR = ${LLVM_DEV_DIR}/ve-csu           # these are not modifiable
BUILDDIR = ${LLVM_DEV_DIR}
LLVM_BUILDDIR = ${BUILDDIR}/build
LLVMDBG_BUILDDIR = ${BUILDDIR}/build-debug
VECSU_BUILDDIR = ${VECSU_SRCDIR}                # this must be equal to SRCDIR
CMPRT_BUILDDIR = ${BUILDDIR}/compiler-rt
UNWIND_BUILDDIR = ${BUILDDIR}/libunwind
CXXABI_BUILDDIR = ${BUILDDIR}/libcxxabi
CXX_BUILDDIR = ${BUILDDIR}/libcxx
OPENMP_BUILDDIR = ${BUILDDIR}/openmp
# RESDIR requires trailing '/'.
RESDIR = ${DEST}/lib/clang/9.0.0/
LIBSUFFIX = /linux/ve/
CSUDIR = ${RESDIR}lib/linux/ve
OPTFLAGS = -O3 -fno-vectorize -fno-slp-vectorize \
	-mllvm -combiner-use-vector-store=false
# llvm test tools are not installed, so need to specify them independently
TOOLDIR = ${LLVM_BUILDDIR}/bin

RM = rm
CMAKE = cmake3
NINJA = ninja-build
THREADS = -j8
CLANG = ${DEST}/bin/clang

all: check-source cmake install libraries
libraries: ve-csu compiler-rt libunwind libcxxabi libcxx openmp

musl:
	make TARGET=ve-linux-musl all

check-source:
	@test -d llvm || echo Need to prepare source code by \"make shallow\"
	@test -d llvm || exit 1

cmake:
	mkdir -p ${LLVM_BUILDDIR}
	cd ${LLVM_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} \
	    TARGET=${BUILD_TARGET} BUILD_TYPE=${BUILD_TYPE} SRCDIR=${SRCDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-llvm.sh

build:
	@test -d ${LLVM_BUILDDIR} || echo Need to cmake first by \"make cmake\"
	@test -d ${LLVM_BUILDDIR} || exit 1
	cd ${LLVM_BUILDDIR} && ${NINJA} ${THREADS}

install: build
	cd ${LLVM_BUILDDIR} && ${NINJA} ${THREADS} install

installall: install ve-csu compiler-rt libunwind libcxxabi libcxx openmp

build-debug:
	make LLVM_BUILDDIR=${LLVMDBG_BUILDDIR} BUILD_TYPE=Debug \
	    ${MFLAGS} cmake
	make LLVM_BUILDDIR=${LLVMDBG_BUILDDIR} BUILD_TYPE=Debug \
	    ${MFLAGS} build

check-llvm: build
	cd ${LLVM_BUILDDIR} && ${NINJA} ${THREADS} check-llvm

check-clang: build
	cd ${LLVM_BUILDDIR} && ${NINJA} ${THREADS} check-clang

ve-csu:
	cd ${VECSU_BUILDDIR} && make CLANG=${CLANG} DEST=${CSUDIR} \
	    TARGET=${TARGET} install

compiler-rt:
	mkdir -p ${CMPRT_BUILDDIR}
	cd ${CMPRT_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} \
	    SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-compiler-rt.sh
	cd ${CMPRT_BUILDDIR} && ${NINJA} ${THREADS} install

# This target is not working at the moment since we don't
# enable sanitizer for VE yet.
check-compiler-rt: compiler-rt
	cd compiler-rt && ${NINJA} ${THREADS} check-builtins
	cd compiler-rt && ${NINJA} ${THREADS} check-sanitizer

libunwind:
	mkdir -p ${UNWIND_BUILDDIR}
	cd ${UNWIND_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} \
	    SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-libunwind.sh
	cd ${UNWIND_BUILDDIR} && ${NINJA} ${THREADS} install

check-libunwind: libunwind
	cd libunwind && ${NINJA} ${THREADS} check-unwind

libcxxabi:
	mkdir -p ${CXXABI_BUILDDIR}
	cd ${CXXABI_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} \
	    SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-libcxxabi.sh
	cd ${CXXABI_BUILDDIR} && ${NINJA} ${THREADS} install

check-libcxxabi: libcxxabi
	cd libcxxabi && ${NINJA} ${THREADS} check-libcxxabi

libcxx:
	mkdir -p ${CXX_BUILDDIR}
	cd ${CXX_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} \
	    SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-libcxx.sh
	cd ${CXX_BUILDDIR} && ${NINJA} ${THREADS} install

check-libcxx: libcxx
	cd libcxx && ${NINJA} ${THREADS} check-libcxx

openmp:
	mkdir -p ${OPENMP_BUILDDIR}
	cd ${OPENMP_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} TARGET=${TARGET} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    RESDIR=${RESDIR} LIBSUFFIX=${LIBSUFFIX} OMPARCH=${OMPARCH} \
	    SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-openmp.sh
	cd ${OPENMP_BUILDDIR} && ${NINJA} ${THREADS} install

check-openmp: openmp
	cd openmp && ${NINJA} ${THREADS} check-openmp

shallow:
	REPO=${REPO} BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${LLVM_DEV_DIR}/scripts/clone-source.sh --depth 1

deep:
	REPO=${REPO} BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${LLVM_DEV_DIR}/scripts/clone-source.sh

shallow-update:
	BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${LLVM_DEV_DIR}/scripts/update-source.sh --depth 1

deep-update:
	BRANCH=${BRANCH} SRCDIR=${SRCDIR} \
	    ${LLVM_DEV_DIR}/scripts/update-source.sh

clean:
	${RM} -rf build compiler-rt libunwind libcxxabi libcxx openmp \
	    build-debug
	-cd ve-csu && make clean

distclean: clean
	${RM} -rf llvm ve-csu
	${RM} -rf ${DEST}

FORCE:

.PHONY: FORCE shallow deep clean dist clean check-source cmake build install \
	libraries ve-csu compiler-rt libunwind libcxxabi libcxx openmp \
	build-debug musl installall
