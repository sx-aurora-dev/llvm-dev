#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_CXX_COMPILER=$DEST/bin/clang++ \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCMAKE_C_COMPILER_TARGET="$TARGET" \
  -DCMAKE_CXX_COMPILER_TARGET="$TARGET" \
  -DLLVM_CONFIG_PATH=$DEST/bin/llvm-config \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_INSTALL_PREFIX="$RESDIR" \
  -DLIBCXXABI_LIBDIR_SUFFIX="$LIBSUFFIX" \
  -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
  -DCMAKE_CXX_FLAGS="-nostdlib++" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DLLVM_PATH=$SRCDIR/llvm \
  -DLLVM_MAIN_SRC_DIR=$SRCDIR/llvm \
  -DLIBCXXABI_USE_COMPILER_RT=True \
  -DLIBCXXABI_HAS_NOSTDINCXX_FLAG=True \
  $SRCDIR/llvm/projects/libcxxabi

# Modify lit.site.cfg to pass installed libraries' path
sed -e '1i config.test_linker_flags        = "-L'$RESDIR'/lib/linux/ve -Wl,-rpath,'$RESDIR'/lib/linux/ve"' \
    -i test/lit.site.cfg

# Add -j1 to lit.py
sed -e 's:lit.py:lit.py -j1:' \
    -i build.ninja
