#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DLLVM_TARGETS_TO_BUILD="$TARGET" \
  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="$EXP_TARGET" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="ve-linux-gnu" \
  -DLLVM_ENABLE_PROJECTS="clang;compiler-rt;libcxx;libcxxabi;libunwind;openmp" \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  $SRCDIR/llvm
