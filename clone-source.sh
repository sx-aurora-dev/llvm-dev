#!/bin/sh

# remove trailing '/'
REPO=`echo $1 | sed -e 's:/$::'`
shift
OPT="$@"

git clone $REPO/llvm.git llvm -b develop $OPT
git clone $REPO/clang.git llvm/tools/clang -b develop $OPT
git clone $REPO/libcxx.git llvm/projects/libcxx -b develop $OPT
git clone $REPO/libcxxabi.git llvm/projects/libcxxabi -b develop $OPT
git clone $REPO/compiler-rt.git llvm/projects/compiler-rt -b develop $OPT
git clone $REPO/libunwind.git llvm/projects/libunwind -b develop $OPT
git clone $REPO/openmp.git llvm/projects/openmp -b develop $OPT
git clone $REPO/ve-csu.git ve-csu $OPT
