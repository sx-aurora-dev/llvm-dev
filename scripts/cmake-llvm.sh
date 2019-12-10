#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DLLVM_TARGETS_TO_BUILD="$TARGET" \
  -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;compiler-rt" \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=on \
  -DBUILD_SHARED_LIBS=on \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  -DRV_ENABLE_SLEEF=on \
  -DRV_ENABLE_VP=on \
  -DRV_ENABLE_CRT=on \
  $SRCDIR/llvm-project/llvm
