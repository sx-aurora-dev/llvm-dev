Development environment for LLVM for NEC SX-Aurora VE
=====================================================

These scripts build a development environment for LLVM for SX-Aurora.
The scripts have been tailored to work on a typical x86-64 vector host.
The main entry point to clone, build and install is the Makefile.


Pre-requesites
==============

The scripts need the following Software Collections on your vector host system:

* devtoolset-9
* rh-python36
* rh-git28
* ninja-build

Install the packages and enter a shell with the packages activated. Eg, by calling:

    scl enable devtoolset-9 rh-python36 rh-git28 bash

Build Procedure
===============

1. Clone this repository:

    `$ git clone <this repository>`

2. Clone all repositories of LLVM for SX-Aurora. The Makefile expects the required git repositories to be available at `<REPOS>` and it will checkout the branch `<BRANCH>` of all of them. For example, if your vector host connects to github, use `https://github.com/sx-aurora-dev` as `<REPOS>` and `hpce/develop` as the `<BRANCH>`. `<BUILD_TYPE>` is passed on to configure the LLVM builds.

    `$ REPOS=<REPO> BRANCH=<BRANCH> BUILD_TYPE=<BUILD_TYPE> make -f llvm-dev/Makefile clone

3. Start the build and install process. The environment variable `BUILD_TYPE` determines how all cmake invocations in the build procedure are configured (either `Debug` or `Release`).

    `$ REPOS=<REPO> BRANCH=<BRANCH> BUILD_TYPE=<BUILD_TYPE> make -f llvm-dev/Makefile install

This will install LLVM for SX-Aurora to `./install` .
You can re-run this script to re-build and re-install everying if you made changes to your local copy.
When the script has finished, you will find the following directory structure:

    $ ls
    build  llvm-dev  src install

Source code is downloaded into `src` direcotry, then llvm is build in `build`
directory and installed to `install`.

4. To active LLVM for SX-Aurora in your shell call `source llvm-dev/enter.sh`.

You can now run `clang --target=ve-linux` to compile C++ code with LLVM for SX-Aurora.

