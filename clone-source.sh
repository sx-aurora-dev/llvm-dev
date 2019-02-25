#!/bin/sh

# Get target REPO and remove trailing '/'
REPO=`echo $1 | sed -e 's:/$::'`
shift

# Treat the rests of arguments as options
OPT="$@"

test -d llvm || git clone $REPO/llvm.git llvm $OPT
test -d llvm/tools/clang || git clone $REPO/clang.git llvm/tools/clang $OPT
test -d llvm/projects/libcxx || \
  git clone $REPO/libcxx.git llvm/projects/libcxx $OPT
test -d llvm/projects/libcxxabi || \
  git clone $REPO/libcxxabi.git llvm/projects/libcxxabi $OPT
test -d llvm/projects/compiler-rt || \
  git clone $REPO/compiler-rt.git llvm/projects/compiler-rt $OPT
test -d llvm/projects/libunwind || \
  git clone $REPO/libunwind.git llvm/projects/libunwind $OPT
test -d llvm/projects/openmp || \
  git clone $REPO/openmp.git llvm/projects/openmp $OPT
test -d ve-csu || \
  git clone $REPO/ve-csu.git ve-csu $OPT
