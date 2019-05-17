#!/bin/sh

$CMAKE -G Ninja \
  -DLIBUNWIND_TARGET_TRIPLE="$TARGET" \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_CXX_COMPILER=$DEST/bin/clang++ \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCMAKE_C_COMPILER_TARGET="$TARGET" \
  -DCMAKE_CXX_COMPILER_TARGET="$TARGET" \
  -DLLVM_CONFIG_PATH=$DEST/bin/llvm-config \
  -DLLVM_ENABLE_LIBCXX=ON \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_INSTALL_PREFIX="$RESDIR" \
  -DLIBUNWIND_LIBDIR_SUFFIX="$LIBSUFFIX" \
  -DCMAKE_CXX_FLAGS="-nostdlib" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_C_FLAGS="-nostdlib" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DLIBUNWIND_LIBCXX_PATH=$SRCDIR/llvm/projects/libcxx \
  -DLLVM_PATH=$SRCDIR/llvm \
  $SRCDIR/llvm/projects/libunwind

# Modify lit.site.cfg to pass installed libraries' path
sed -e 's:^config.test_linker_flags.*$:config.test_linker_flags        = "-L'$RESDIR'/lib/linux/ve -Wl,-rpath,'$RESDIR'/lib/linux/ve":' \
    -i test/lit.site.cfg

# Modify lit.site.cfg to enable builtins_library
sed -e 's:^config.builtins_library.*$:config.builtins_library         = "'$RESDIR/lib/linux/libclang_rt.builtins-ve.a'":' \
    -i test/lit.site.cfg

# Add -j1 to llvm-lit
sed -e 's: /llvm-lit: '$TOOLDIR'/llvm-lit -j1:' \
    -i build.ninja
