THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
LLVMDEV = $(abspath $(dir ${THIS_MAKEFILE_PATH})/)
WSPACE?=$(PWD)
PREFIX?=${WSPACE}/install

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
	@echo "    LLVM_BUILD_TYPE=Release|Debug"
	@echo "        The LLVM build type."
	@echo "        Currently: ${LLVM_BUILD_TYPE}"
	@echo ""
	@echo "== OPTIONAL VARIABLES =="
	@echo ""
	@echo "    WSPACE=<workspace_path>"
	@echo "        The path where everything is checked out, build and installed."
	@echo "        Currently: ${WSPACE}" 
	@echo ""
	@echo "    PREFIX=<where_to_install>"
	@echo "        The path prefix used for installing."
	@echo "        Currently: ${PREFIX}" 
	@echo ""
	@echo ""
	@echo "== TARGETS =="
	@echo ""
	@echo "    make clone CLONEOPTS=<options passed to clone>"
	@echo "        Call 'git clone <CLONEOPTS>'."
	@echo ""
	@echo "    make install:"
	@echo "        Build and install the stack to ${PREFIX}"
	@echo ""
	@echo ""
	@echo "== DIRECTORIES =="
	@echo ""
	@echo "    Workspace path: ${WSPACE}"
	@echo "    Install prefix: ${PREFIX}"


# Retrieve all sources from this repo's parent
REPOS ?= $(error "Missing REPOS: root of sx-aurora-dev llvm repositories.")
BRANCH ?= $(error "Missing BRANCH: branches to build installation from")
LLVM_BUILD_TYPE ?= $(error "Missing LLVM_BUILD_TYPE: Release|RelWithDebInfo|Debug")
BUILD_TARGET = "VE;X86"
OMPARCH = ve

# tools
NINJA?=ninja-build
CMAKE?=cmake

# RESDIR requires trailing '/'.
OPTFLAGS = -O3

RM = rm
RMDIR = rmdir
THREADS = -j8
CLANG = ${DEST}/bin/clang

MONOREPO=${WSPACE}/llvm-project

# TODO: Restore vendor tag
# CLANG_VENDOR?=llvm-ve-rv-dev

clone:
	git clone ${CLONEOPTS} ${REPOS}/llvm-project.git -b ${BRANCH} --recurse-submodules ${MONOREPO}

install:
	make -f ${LLVMDEV}/ve-linux-steps.make BUILDROOT=${WSPACE}/build PREFIX=${PREFIX} MONOREPO=${MONOREPO} LLVM_BUILD_TYPE=${LLVM_BUILD_TYPE} install

.PHONY: install
