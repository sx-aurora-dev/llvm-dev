#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DLLVM_TARGETS_TO_BUILD="$TARGET" \
  -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;compiler-rt" \
  -DRV_ENABLE_CRT=on \
  -DBUILD_SHARED_LIBS=on \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  $SRCDIR/llvm-project/llvm
