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
  -DLIBCXX_USE_COMPILER_RT=True \
  -DLIBCXX_TARGET_TRIPLE=$TARGET \
  -DLLVM_CONFIG_PATH=$DEST/bin/llvm-config \
  -DLLVM_DEFAULT_TARGET_TRIPLE=$TARGET \
  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
  -DLIBCXXABI_USE_LLVM_UNWINDER=True \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$SRCDIR/libcxxabi/include \
  -DLIBCXX_USE_COMPILER_RT=True \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_CXX_FLAGS="-nostdlib++" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DLIBCXX_ENABLE_STATIC=OFF \
  $SRCDIR/libcxx

# Force to remove isntall path from compiled libraries.
# cmake leave compiled directory in .so file unfortunately.
#sed -e "s;:$DEST/lib;;" \
#  -i build.ninja

# Modify lit.site.cfg to pass installed libraries' path
#sed -e 's:^config.test_linker_flags.*$:config.test_linker_flags        = "-L'$RESDIR'/lib/linux/ve -Wl,-rpath,'$RESDIR'/lib/linux/ve":' \
#    -i test/lit.site.cfg

# Modify lit.site.cfg to enable llvm_unwinder
#sed -e 's:^config.llvm_unwinder.*$:config.llvm_unwinder            = True:' \
#    -i test/lit.site.cfg

# Add -j1 to lit.py
sed -e 's:lit.py:lit.py -j1:' \
    -i build.ninja
