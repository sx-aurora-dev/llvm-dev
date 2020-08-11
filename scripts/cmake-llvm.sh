#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DLLVM_TARGETS_TO_BUILD="$TARGET" \
  -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;compiler-rt;openmp" \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=on \
  -DBUILD_SHARED_LIBS=on \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  -DLLVM_RVPLUG_LINK_INTO_TOOLS:BOOL=ON \
  -DRV_ENABLE_SLEEF=on \
  -DRV_ENABLE_VP=on \
  -DRV_ENABLE_CRT=off \
  -DCLANG_VENDOR=${CLANG_VENDOR} \
  -DCLANG_REPOSITORY_STRING=https://github.com/sx-aurora-dev/llvm-project.git \
  $SRCDIR/llvm-project/llvm
