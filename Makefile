THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
# LLVM_DEV_DIR requires to use an abosolute path
LLVM_DEV_DIR = $(abspath $(dir ${THIS_MAKEFILE_PATH}))

# Retrieve all sources from this repo's parent
REPO = $(dir $(shell cd ${LLVM_DEV_DIR} && git config remote.origin.url))
BRANCH = develop
BUILD_TYPE = Release
X86_TRIPLE = x86_64-unknown-linux-gnu
VE_TRIPLE = ve-unknown-linux-gnu

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
LIBOMPTARGET_BUILDDIR = ${BUILDDIR}/libomptarget
# RESDIR requires trailing '/'.
LLVM_VERSION_MAJOR = $(shell grep 'set.*LLVM_VERSION_MAJOR  *' ${SRCDIR}/llvm/CMakeLists.txt | sed -e 's/.*LLVM_VERSION_MAJOR //' -e 's/[^0-9][^0-9]*//')
RESDIR = ${DEST}/lib/clang/${LLVM_VERSION_MAJOR}/
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

all: check-source cmake install

check-source:
	@test -d ${SRCDIR} || echo Need to prepare source code by \
	    \"make shallow\"
	@test -d ${SRCDIR} || exit 1

cmake:
	mkdir -p ${LLVM_BUILDDIR}
	cd ${LLVM_BUILDDIR} && CMAKE=${CMAKE} DEST=${DEST} \
	    BUILD_TYPE=${BUILD_TYPE} SRCDIR=${SRCDIR} \
	    COMPILE_THREADS=${COMPILE_THREADS} LINK_THREADS=${LINK_THREADS} \
	    ${LLVM_DEV_DIR}/scripts/cmake-ve.sh

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

dist:
	mkdir -p ${LLVM_DISTBUILDDIR}
	cd ${LLVM_DISTBUILDDIR} && CMAKE=${CMAKE} DEST=${LLVM_DISTDIR} \
	    COMPILE_THREADS=${COMPILE_THREADS} LINK_THREADS=${LINK_THREADS} \
	    SRCDIR=${SRCDIR} ${LLVM_DEV_DIR}/scripts/cmake-dist.sh
	cd ${LLVM_DISTBUILDDIR} && ${NINJA} stage2-distribution
	cd ${LLVM_DISTBUILDDIR} && ${NINJA} stage2-install-distribution

install: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} install

installall: install

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

# This target is not working at the moment since we don't
# enable sanitizer for VE yet.
check-compiler-rt: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-compiler-rt-${VE_TRIPLE}

check-libunwind: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-unwind-${VE_TRIPLE}

check-libcxxabi: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-cxxabi-${VE_TRIPLE}

check-libcxx: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-cxx-${VE_TRIPLE}

check-openmp: build
	cd ${LLVM_BUILDDIR} && ${NINJA} -j${COMPILE_THREADS} check-openmp-${VE_TRIPLE}

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
	${RM} -rf ${LLVM_BUILDDIR} ${LLVMDBG_BUILDDIR} ${DEST}
	-${RMDIR} ${BUILDDIR}

distclean: clean
#	${RM} -rf ${SRCDIR}

FORCE:

.PHONY: FORCE shallow deep clean dist clean check-source cmake build install \
	build-debug install-debug installall
