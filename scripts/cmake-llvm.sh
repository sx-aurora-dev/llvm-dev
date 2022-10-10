#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DLLVM_TARGETS_TO_BUILD="$BUILD_TARGET" \
  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="$EXP_TARGET" \
  -DLLVM_ENABLE_PROJECTS="clang;compiler-rt" \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;openmp" \
  -DLLVM_RUNTIME_TARGETS="$TARGET" \
  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
  -DRUNTIMES_x86_64-unknown-linux-gnu_OPENMP_STANDALONE_BUILD=ON \
  -DRUNTIMES_x86_64-unknown-linux-gnu_OPENMP_LIBDIR_SUFFIX="/$TARGET" \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_ENABLE_ZLIB=OFF \
  -DLLVM_ENABLE_ZSTD=OFF \
  $SRCDIR/llvm

# Disable TERMINFO and ZLIB since those are enabled by default and cause
# compile error in libomptarget.  I believe the source of problem is
# libomptarget since accelarator never requires terminfo.
