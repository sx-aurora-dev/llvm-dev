Easy to use developing environment for LLVM for NEC SX-Aurora VE
================================================================

This repository contains Makefile and scripts to create a developing
environment for LLVM for NEC SX-Aurora VE.

LLVM requires multiple repositories to combine and LLVM for VE requires
multiple libraries' cross-compile.  Those are little difficult to handle
at the beginning.  So, I made this easy to use developing environment.

These are quick steps to compile LLVM for VE.  However, if you are going
to work on LLVM for VE, I recommend to use `make` directly like explained
later.

Quick step (compile only)
=========================

    $ git clone <this repository>
    $ ./llvm-dev/clone.sh
    $ scl enable devtoolset-8 bash
    $ ./llvm-dev/build-and-install.sh <install directory>
    $ ls
    build  llvm-dev  src

Source code is downloaded into `src` direcotry, then llvm is build in `build`
directory and installed to `<install direcotry>`.

You can change the directories and build type as below.

    $ SRCDIR=src2 ./llvm-dev/clone.ch
    $ SRCDIR=src2 BUILD_DIR=build-debug BUILD_TYPE=Debug ./llvm-dev/build-and-install.sh ~/.local-debug

Prerequisites
=============

  - cmake (cmake3 in RHEL7)
  - ninja (ninja-build in RHEL7)
  - gcc 5.1 or above (devtoolset-8 in RHEL7)

Repositories
============

We maintain multiple repositories, one for public and one for internal.
We prepare multiple branches for multiple repositoris, so please clone
correct one.

    $ git clone <this repository>

Prepare source codes
====================

There are two ways to clone source code, shallow one and deep one.  If
you simply want to git it try, please use shallow one.  If you are
developing for LLVM for VE, please use deep one.  Recent git, 1.9 or
above, allows fetch and push to/from shallow repositories, so shallow
may work for developing.

    $ make shallow
    $ ls llvm

or

    $ make deep
    $ ls llvm

Compile and install
===================

Compile clang/llvm for VE, install clang/llvm under ./install directory,
cross-compile libraries using installed clang/llvm for VE, and install
generated cross-compiled libraries under ./install directory by following
command.

    $ scl enable devtoolset-8 bash   # enable latest gcc on RHEL7
    $ make

You can install everything to your favorite place by following command.

    $ make DEST=~/.local             # need to use an absolute path

Compile without installation
============================

You can compile clang/llvm without installation by following command.

    $ scl enable devtoolset-8 bash   # enable latest gcc on RHEL7
    $ make build

Clang/llvm requires installed header files, so please install them
by following command before use them.

    $ make install

Debug mode compile
==================

Compile clang/llvm in debug mode by following command.  Compiled
clang/llvm are left in independent directory named build-debug.

    $ scl enable devtoolset-8 bash   # enable latest gcc on RHEL7
    $ make build-debug

Debug mode everything
=====================

It is also possible to compile and install everything under debug mode
by following command.

    $ scl enable devtoolset-8 bash   # enable latest gcc on RHEL7
    $ make clean                     # remove compiled binaries first
    $ make BUILD_TYPE=Debug

Update sources
==============

You can update your deep cloned source code by following commands.
This simply performs "git fetch origin develop:develop -u" on each
subdirectory.  You may see errors if you modified local develop
branch.  Please fix such problems by yourself.

    $ make deep-update

You can update your shwllow cloned source code by following commands.
This may overwrite your modified $BRANCH branch.  Please be careful
before use this.  If you have a problem with this command,
"git reflog" is your friend.

    $ make shallow-update BRANCH=github_release_20190212

Run tests
=========

Tests are never executed by above commands.  It is required to
run them explicitly like below if you want to perform tests.

You can test compiled clang by following command.

    $ make check-clang

You can test compiled llvm by following command.

    $ make check-llvm

You can test cross-compiled libraries on VE by following command.

    $ make check-libunwind
    $ make check-libcxxabi
    $ make check-libcxx
    $ make check-openmp

