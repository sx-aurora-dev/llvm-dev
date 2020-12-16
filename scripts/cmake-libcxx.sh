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
  -DLIBCXXABI_USE_LLVM_UNWINDER=True \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$SRCDIR/llvm-project/libcxxabi/include \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_CXX_FLAGS="-nostdlib++" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DLIBCXX_ENABLE_SHARED=Off \
  -DLIBCXX_USE_COMPILER_RT=True \
  $SRCDIR/llvm-project/libcxx

# Disabling shared libc++ for now because of runtime issues,

# Force to remove isntall path from compiled libraries.
# cmake leave compiled directory in .so file unfortunately.
sed -e "s;:$DEST/lib;;" \
  -i build.ninja

# Modify lit.site.cfg to pass installed libraries' path
sed -e 's:^config.test_linker_flags.*$:config.test_linker_flags        = "-L'$RESDIR'/lib/linux/ve -Wl,-rpath,'$RESDIR'/lib/linux/ve":' \
    -i test/lit.site.cfg

# Modify lit.site.cfg to enable llvm_unwinder
sed -e 's:^config.llvm_unwinder.*$:config.llvm_unwinder            = True:' \
    -i test/lit.site.cfg

# Add -j1 to lit.py
sed -e 's:lit.py:lit.py -j1:' \
    -i build.ninja
