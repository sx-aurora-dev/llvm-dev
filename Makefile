THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
# LLVM_DEV_DIR requires to use an abosolute path
LLVM_DEV_DIR = $(abspath $(dir ${THIS_MAKEFILE_PATH}))

# Retrieve all sources from this repo's parent
REPO = $(dir $(shell cd ${LLVM_DEV_DIR} && git config remote.origin.url))
BRANCH = develop
BUILD_TYPE = Release
BUILD_TARGET = "X86"
EXP_TARGET = "VE"
X86_TRIPLE = x86_64-unknown-linux-gnu
VE_TRIPLE = ve-unknown-linux-gnu
OMPARCH = ve

# DEST, SRCDIR, BUILDDIR and others requires to use an abosolute path
DEST = ${LLVM_DEV_DIR}/install
DBG_DEST = ${LLVM_DEV_DIR}/install-debug
SRCDIR = ${LLVM_DEV_DIR}/llvm-project
BUILDDIR = ${LLVM_DEV_DIR}
LLVM_BUILDDIR = ${BUILDDIR}/build
LLVM_VEBUILDDIR = ${BUILDDIR}/ve-build
LLVM_DISTBUILDDIR = ${BUILDDIR}/dist-build
LLVM_DISTDIR = ${BUILDDIR}/dist
LLVMDBG_BUILDDIR = ${BUILDDIR}/build-debug
CMPRT_BUILDDIR = ${BUILDDIR}/compiler-rt
RUNTIMES_BUILDDIR = ${BUILDDIR}/runtimes
OPENMP_BUILDDIR = ${BUILDDIR}/openmp
LIBOMPTARGET_BUILDDIR = ${BUILDDIR}/libomptarget
# RESDIR requires trailing '/'.
LLVM_VERSION_MAJOR = $(shell grep 'set.*LLVM_VERSION_MAJOR  *' ${SRCDIR}/llvm/CMakeLists.txt | sed -e 's/.*LLVM_VERSION_MAJOR //' -e 's/[^0-9][^0-9]*//')
RESDIR = ${DEST}/lib/clang/${LLVM_VERSION_MAJOR}/
LIBSUFFIX = /linux/ve/
#CSUDIR = ${RESDIR}lib/linux/ve
OPTFLAGS = -O3
COMPILER_RT_TEST_OPTFLAGS = -O0
# llvm test tools are not installed, so need to specify them independently
TOOLDIR = ${LLVM_BUILDDIR}/bin

RM = rm
RMDIR = rmdir
CMAKE = cmake3
NINJA = ninja-build
COMPILE_THREADS = 6
LINK_THREADS = 3
CLANG = ${DEST}/bin/clang

all: check-source cmake install libraries
libraries: compiler-rt runtimes openmp

check-source:
	@test -d ${SRCDIR} || echo Need to prepare source code by \
	    \"make shallow\"
	@test -d ${SRCDIR} || exit 1

cmake:
	mkdir -p ${LLVM_BUILDDIR}
	cd ${LLVM_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} \
	    BUILD_TYPE=${BUILD_TYPE} TARGET=${X86_TRIPLE} \
	    BUILD_TARGET=${BUILD_TARGET} EXP_TARGET=${EXP_TARGET} \
	    COMPILE_THREADS=${COMPILE_THREADS} LINK_THREADS=${LINK_THREADS} \
	    SRCDIR=${SRCDIR} ${LLVM_DEV_DIR}/scripts/cmake-llvm.sh

build:
	@test -d ${LLVM_BUILDDIR} || echo Need to cmake first by \"make cmake\"
	@test -d ${LLVM_BUILDDIR} || exit 1
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS}

ve:
	mkdir -p ${LLVM_VEBUILDDIR}
	cd ${LLVM_VEBUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} \
	    BUILD_TYPE=${BUILD_TYPE} SRCDIR=${SRCDIR} \
	    COMPILE_THREADS=${COMPILE_THREADS} LINK_THREADS=${LINK_THREADS} \
	    ${LLVM_DEV_DIR}/scripts/cmake-ve.sh
	cd ${LLVM_VEBUILDDIR} && ${NINJA} distribution
	cd ${LLVM_VEBUILDDIR} && ${NINJA} install-distribution

ve-debug:
	mkdir -p ve-debug
	cd ve-debug && CMAKE=${CMAKE} DEST=${DEST} \
	    BUILD_TYPE=Debug SRCDIR=${SRCDIR} \
	    COMPILE_THREADS=${COMPILE_THREADS} LINK_THREADS=${LINK_THREADS} \
	    ${LLVM_DEV_DIR}/scripts/cmake-ve.sh
	cd ve-debug && ${NINJA} distribution

dist:
	mkdir -p ${LLVM_DISTBUILDDIR}
	cd ${LLVM_DISTBUILDDIR} && CMAKE=${CMAKE} DEST=${LLVM_DISTDIR} \
	    COMPILE_THREADS=${COMPILE_THREADS} LINK_THREADS=${LINK_THREADS} \
	    SRCDIR=${SRCDIR} ${LLVM_DEV_DIR}/scripts/cmake-dist.sh
	cd ${LLVM_DISTBUILDDIR} && ${NINJA} stage2-distribution
	cd ${LLVM_DISTBUILDDIR} && ${NINJA} stage2-install-distribution

install: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} install

installall: install compiler-rt runtimes openmp

build-debug:
	make LLVM_BUILDDIR=${LLVMDBG_BUILDDIR} DEST=${DBG_DEST} \
	    BUILD_TYPE=Debug ${MFLAGS} cmake
	make LLVM_BUILDDIR=${LLVMDBG_BUILDDIR} DEST=${DBG_DEST} \
	    BUILD_TYPE=Debug ${MFLAGS} build

install-debug:
	make LLVM_BUILDDIR=${LLVMDBG_BUILDDIR} DEST=${DBG_DEST} \
	    BUILD_TYPE=Debug ${MFLAGS} install

check-llvm: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-llvm

check-clang: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-clang

compiler-rt:
	mkdir -p ${CMPRT_BUILDDIR}
	cd ${CMPRT_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} RESDIR=${RESDIR} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    COMPILER_RT_TEST_OPTFLAGS="${COMPILER_RT_TEST_OPTFLAGS}" \
	    TARGET=${VE_TRIPLE} SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-compiler-rt.sh
	cd ${CMPRT_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} install

# This target is not working at the moment since we don't
# enable sanitizer for VE yet.
check-compiler-rt: compiler-rt
	cd compiler-rt && ${NINJA} -j${COMPILE_THREADS} check-builtins
#	cd compiler-rt && ${NINJA} -j${COMPILE_THREADS} check-compiler-rt (will check CRT)

runtimes:
	mkdir -p ${RUNTIMES_BUILDDIR}
	cd ${RUNTIMES_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} \
            RESDIR=${RESDIR} BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    TARGET=${VE_TRIPLE} SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-runtimes.sh
	cd ${RUNTIMES_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} install

check-libunwind: runtimes
	cd ${RUNTIMES_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-unwind

check-libcxxabi: runtimes
	cd ${RUNTIMES_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-cxxabi

check-libcxx: runtimes
	cd ${RUNTIMES_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-cxx

openmp:
	mkdir -p ${OPENMP_BUILDDIR}
	cd ${OPENMP_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} RESDIR=${RESDIR} \
	    BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    TARGET=${VE_TRIPLE} SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-openmp.sh
	cd ${OPENMP_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} install

check-openmp: openmp
	cd openmp && ${NINJA} -j${COMPILE_THREADS} check-openmp

libomptarget:
	mkdir -p ${LIBOMPTARGET_BUILDDIR}
	cd ${LIBOMPTARGET_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} \
	    RESDIR=${RESDIR} BUILD_TYPE=${BUILD_TYPE} OPTFLAGS="${OPTFLAGS}" \
	    TARGET=${VE_TRIPLE} SRCDIR=${SRCDIR} TOOLDIR=${TOOLDIR} \
	    ${LLVM_DEV_DIR}/scripts/cmake-libomptarget.sh
	cd ${LIBOMPTARGET_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} install

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
	${RM} -rf ${LLVM_BUILDDIR} ${CMPRT_BUILDDIR} ${RUNTIMES_BUILDDIR} \
            ${OPENMP_BUILDDIR} ${LLVMDBG_BUILDDIR} ${DEST}
	-${RMDIR} ${BUILDDIR}

distclean: clean
#	${RM} -rf ${SRCDIR}

FORCE:

.PHONY: FORCE shallow deep clean dist clean check-source cmake build install \
	libraries compiler-rt runtimes openmp \
	build-debug install-debug installall
