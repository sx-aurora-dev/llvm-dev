Development environment for LLVM for NEC SX-Aurora VE
=====================================================

These scripts build a development environment for LLVM for SX-Aurora.
The scripts have been tailored to work on a x86-64 vector host with CentOS 8.
The main entry point to clone, build and install is the Makefile.


Pre-requesites
==============

The scripts need the following Software Collections on your vector host system:

* gcc-toolchain-10
* rh-python36
* rh-git28
* ninja-build

Install the packages and enter a shell with the packages activated. Eg, by
calling:

    scl enable gcc-toolchain-10 rh-python36 rh-git28 bash

Build Procedure
===============

Clone this repository:

    $ git clone <this repository>

Clone all repositories of LLVM for SX-Aurora. The Makefile expects the required
git repositories to be available at `<REPOS>` and it will checkout the branch
`<BRANCH>` of all of them. For example, if your vector host connects to github,
use `https://github.com/sx-aurora-dev` as `<REPOS>` and `hpce/develop` as the
`<BRANCH>`. `<BUILD_TYPE>` is passed on to configure the LLVM builds.

    $ REPOS=<REPO> BRANCH=<BRANCH> LLVM_BUILD_TYPE=<BUILD_TYPE> make -f llvm-dev/Makefile clone

Start the build and install process. The environment variable `BUILD_TYPE`
determines how all cmake invocations in the build procedure are configured
(either `Debug` or `Release`).

    $ REPOS=<REPO> BRANCH=<BRANCH> LLVM_BUILD_TYPE=<BUILD_TYPE> make -f llvm-dev/Makefile install

This will install LLVM for SX-Aurora to `./install` .  You can re-run this
script to re-build and re-install everying if you made changes to your local
copy.  When the script has finished, you will find the following directory
structure:

    $ ls
    build_llvm  build_<runtime>_ve  llvm-dev  llvm-project  install

Source code is downloaded into `src` direcotry, then llvm is build in
`build_llvm` directory and installed to `install`. There is a separate
`build_<runtime>_ve` folder for each runtime library that is built for VE.

To active LLVM for SX-Aurora in your shell call `source llvm-dev/enter.sh`.

You can now run `clang++ --target=ve-linux` to compile C++ code with LLVM for
SX-Aurora.
