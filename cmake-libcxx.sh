#!/bin/sh

case $TARGET in
*-musl) MUSL="-DLIBCXX_HAS_MUSL_LIBC=True";;
*)      MUSL="";;
esac

$CMAKE -G Ninja \
  $MUSL \
  -DLIBCXX_USE_COMPILER_RT=True \
  -DLIBCXX_TARGET_TRIPLE="$TARGET" \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_CXX_COMPILER=$DEST/bin/clang++ \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCMAKE_C_COMPILER_TARGET="$TARGET" \
  -DCMAKE_CXX_COMPILER_TARGET="$TARGET" \
  -DLLVM_CONFIG_PATH=$DEST/bin/llvm-config \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_INSTALL_PREFIX="$RESDIR" \
  -DLIBCXX_LIBDIR_SUFFIX="$LIBSUFFIX" \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=../llvm/projects/libcxxabi/include \
  -DCMAKE_C_FLAGS="-nostdlib++" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_CXX_FLAGS="-nostdlib++" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  ../llvm/projects/libcxx
