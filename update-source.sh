#!/bin/sh

OPT="$@"

# Add -u option (update-head-ok) to update current branch
OPT="-u $OPT"

# Add -f option (force) for the case of shallow fetch
case "$OPT" in
*"--depth 1") OPT="-f $OPT";;
*) ;;
esac

TOP=`pwd`
cd $TOP/llvm; git fetch origin develop:develop $OPT
cd $TOP/llvm/tools/clang; git fetch origin develop:develop $OPT
cd $TOP/llvm/projects/libcxx; git fetch origin develop:develop $OPT
cd $TOP/llvm/projects/libcxxabi; git fetch origin develop:develop $OPT
cd $TOP/llvm/projects/compiler-rt; git fetch origin develop:develop $OPT
cd $TOP/llvm/projects/libunwind; git fetch origin develop:develop $OPT
cd $TOP/llvm/projects/openmp; git fetch origin develop:develop $OPT
cd $TOP/ve-csu; git fetch origin develop:develop $OPT
