#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_CXX_COMPILER=$DEST/bin/clang++ \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCMAKE_C_COMPILER_TARGET=$TARGET \
  -DCMAKE_CXX_COMPILER_TARGET=$TARGET \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  -DLLVM_CONFIG_PATH=$DEST/bin/llvm-config \
  -DLLVM_DEFAULT_TARGET_TRIPLE=$TARGET \
  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
  -DLLVM_PATH=$SRCDIR/llvm \
  -DLLVM_MAIN_SRC_DIR=$SRCDIR/llvm \
  -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
  -DLIBCXXABI_USE_COMPILER_RT=True \
  -DLIBCXXABI_HAS_NOSTDINCXX_FLAG=True \
  -DLIBCXXABI_LIBCXX_INCLUDES="$DEST/include/c++/v1/" \
  -DCMAKE_CXX_FLAGS="-nostdlib++ -I$DEST/include/$TARGET/c++/v1/" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  $SRCDIR/libcxxabi

# Modify lit.site.cfg to pass installed libraries' path
#sed -e '1i config.test_linker_flags        = "-L'$RESDIR'/lib/linux/ve -Wl,-rpath,'$RESDIR'/lib/linux/ve"' \
#    -i test/lit.site.cfg

# Add -j1 to lit.py
sed -e 's:lit.py:lit.py -j1:' \
    -i build.ninja
