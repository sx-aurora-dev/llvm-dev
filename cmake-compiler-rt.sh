#!/bin/sh

$CMAKE -G Ninja \
  -DCOMPILER_RT_BUILD_BUILTINS=ON \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_PROFILE=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_C_COMPILER_TARGET="$TARGET" \
  -DCMAKE_ASM_COMPILER_TARGET="$TARGET" \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
  -DLLVM_CONFIG_PATH=$DEST/bin/llvm-config \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_INSTALL_PREFIX="$RESDIR" \
  -DCMAKE_CXX_FLAGS="-nostdlib" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_C_FLAGS="-nostdlib" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  ${SRCDIR:=..}/llvm/projects/compiler-rt 
