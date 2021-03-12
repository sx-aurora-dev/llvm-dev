THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
LLVMDEV = $(abspath $(dir ${THIS_MAKEFILE_PATH})/)
WSPACE?=$(PWD)
INSTALL_PREFIX?=${WSPACE}/install
BUILDDIR = ${WSPACE}/build
SCRIPTS=${LLVMDEV}/scripts

all: help

help:
	@echo "=== Makefile for the LLVM for SX-Aurora stack ==="
	@echo ""
	@echo "== MANDATORY VARIABLES =="
	@echo ""
	@echo "You need to set these three variables to make any target:"
	@echo ""
	@echo "    REPOS=<path-or-url/to/repos>"
	@echo "        This is common prefix of the path/url of the repos."
	@echo "        Currently: ${REPOS}"
	@echo ""
	@echo "    BRANCH=<branch>"
	@echo "        The branch name that will be checked out on all repos."
	@echo "        Currently: ${BRANCH}"
	@echo ""
	@echo "    BUILD_TYPE=Release|Debug"
	@echo "        The build type."
	@echo "        Currently: ${BUILD_TYPE}"
	@echo ""
	@echo "== OPTIONAL VARIABLES =="
	@echo ""
	@echo "    WSPACE=<workspace_path>"
	@echo "        The path where everything is checked out, build and installed."
	@echo "        Currently: ${WSPACE}" 
	@echo ""
	@echo "    INSTALL_PREFIX=<where_to_install"
	@echo "        The path prefix used for installing."
	@echo "        Currently: ${INSTALL_PREFIX}" 
	@echo ""
	@echo ""
	@echo "== TARGETS =="
	@echo ""
	@echo "    make clone[-deep or -shallow]"
	@echo "        Deep (default) or shallow clone all required repos."
	@echo ""
	@echo "    make update[-deep or -shallow]"
	@echo "        Deep (default) or shallow update the repos."
	@echo ""
	@echo "    make install:"
	@echo "        Build and install the stack to ${INSTALL_PREFIX}"
	@echo ""
	@echo ""
	@echo "== DIRECTORIES =="
	@echo ""
	@echo "    Workspace path: ${WSPACE}"
	@echo "    Build directory: ${BUILDDIR}"
	@echo "    Install prefix: ${INSTALL_PREFIX}"


# Retrieve all sources from this repo's parent
REPOS ?= $(error "Missing REPOS: root of sx-aurora-dev llvm repositories.")#  $(dir $(shell cd ${WSPACE} && git config remote.origin.url))
BRANCH ?= $(error "Missing BRANCH: branches to build installation from") # hpce/develop)
BUILD_TYPE ?= $(error "Missing BUILD_TYPE: Release|RelWithDebInf|Debug") # Debug
BUILD_TARGET = "VE;X86"
TARGET = ve-linux
OMPARCH = ve

# tools
NINJA?=ninja-build
CMAKE?=cmake

# RESDIR requires trailing '/'.
OPTFLAGS = -O3
# llvm test tools are not installed, so need to specify them independently
TOOLDIR = ${LLVM_BUILDDIR}/bin

RM = rm
RMDIR = rmdir
THREADS = -j8
CLANG = ${DEST}/bin/clang

LLVMPROJECT=${WSPACE}/llvm-project
CACHES=${LLVMPROJECT}/clang/cmake/caches

# Tag the build
CLANG_VENDOR?=llvm-ve-rv-dev

BUILDDIR_STAGE_1=${BUILDDIR}/build_stage_1
BUILDDIR_STAGE_2=${BUILDDIR}/build_stage_2
BUILDDIR_STAGE_3=${BUILDDIR}/build_stage_3

TMP_INSTALL_STAGE3=${BUILDDIR}/tmp_install_stage3

install: install-stage3

# Stage 3 steps (OpenMP for VE)
check-stage3: build-stage3
	cd ${BUILDDIR_STAGE_3} && ${NINJA} check-all

install-stage3: build-stage3
	cp ${BUILDDIR_STAGE_3}/runtime/src/*.so ${INSTALL_PREFIX}/lib/ve-linux
	cp ${BUILDDIR_STAGE_3}/libomptarget/*.so ${INSTALL_PREFIX}/lib/ve-linux

build-stage3: configure-stage3
	cd ${BUILDDIR_STAGE_3} && ${NINJA}

configure-stage3: install-stage2
	mkdir -p ${BUILDDIR_STAGE_3}
	cd ${BUILDDIR_STAGE_3} && ${CMAKE} -G Ninja ${LLVMPROJECT}/openmp \
		                           -DCMAKE_INSTALL_PREFIX=${TMP_INSTALL_STAGE3} \
					   -DLIBOMP_ARCH=ve \
					   -DOPENMP_FILECHECK_EXECUTABLE=${INSTALL_PREFIX}/bin/FileCheck \
					   -DOPENMP_NOT_EXECUTABLE=${INSTALL_PREFIX}/bin/FileCheck \
					   -DLIBOMP_USE_ADAPTIVE_LOCKS=Off \
					   -DLIBOMP_OMPT_SUPPORT=Off \
					   -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
					   -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
					   -DCMAKE_CXX_FLAGS=--target=ve-linux \
					   -DCMAKE_C_FLAGS=--target=ve-linux


# Stage 2 steps (Self-hosting Clang, OpenMP for X86)
check-stage2: build-stage2
	cd ${BUILDDIR_STAGE_2} && ${NINJA} check-all

install-stage2: build-stage2
	cd ${BUILDDIR_STAGE_2} && ${NINJA} install

build-stage2: configure-stage2
	cd ${BUILDDIR_STAGE_2} && ${NINJA}

configure-stage2: install-stage1
	mkdir -p ${BUILDDIR_STAGE_2}
	cd ${BUILDDIR_STAGE_2} && ${CMAKE} -G Ninja ${LLVMPROJECT}/llvm -DLLVM_ENABLE_RTTI=on -DBOOTSTRAP_PREFIX=${INSTALL_PREFIX} -C ${CACHES}/VectorEngine-Stage-2.cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}


# Stage 1 steps (Clang++ for VH and VE)
check-stage1: build-stage1
	cd ${BUILDDIR_STAGE_1} && ${NINJA} check-all

install-stage1: build-stage1
	cd ${BUILDDIR_STAGE_1} && ${NINJA} install

build-stage1: configure-stage1
	cd ${BUILDDIR_STAGE_1} && ${NINJA}

configure-stage1:
	mkdir -p ${BUILDDIR_STAGE_1}
	cd ${BUILDDIR_STAGE_1} && ${CMAKE} -G Ninja ${LLVMPROJECT}/llvm -C ${CACHES}/VectorEngine-Stage-1.cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}

clone-shallow:
	REPOS=${REPOS} BRANCH=${BRANCH} WSPACE=${WSPACE} \
	    ${SCRIPTS}/clone-source.sh --depth 1

clone: clone-deep

clone-deep:
	REPOS=${REPOS} BRANCH=${BRANCH} WSPACE=${WSPACE} \
	    ${SCRIPTS}/clone-source.sh

update: update-deep

update-shallow:
	BRANCH=${BRANCH} WSPACE=${WSPACE} \
	    ${SCRIPTS}/update-source.sh --depth 1

update-deep:
	BRANCH=${BRANCH} WSPACE=${WSPACE} \
	    ${SCRIPTS}/update-source.sh

clean:
	${RM} -rf ${BUILDDIR_STAGE_1} ${BUILDDIR_STAGE_2}

FORCE:

.PHONY: FORCE clone-shallow clone-deep update-shallow update-deep \
	build-stage1 configure-stage1 install-stage1 \
	build-stage2 configure-stage2 install-stage2 \
	all help
