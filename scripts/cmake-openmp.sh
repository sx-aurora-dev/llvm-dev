#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_CXX_COMPILER=$DEST/bin/clang++ \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCMAKE_C_COMPILER_TARGET="$TARGET" \
  -DCMAKE_CXX_COMPILER_TARGET="$TARGET" \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_INSTALL_PREFIX="$RESDIR" \
  -DOPENMP_LIBDIR_SUFFIX="$LIBSUFFIX" \
  -DCMAKE_CXX_FLAGS="" \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_C_FLAGS="" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DLIBOMP_ARCH="$OMPARCH" \
  -DOPENMP_LLVM_TOOLS_DIR=$TOOLDIR \
  $SRCDIR/llvm/projects/openmp

# Modify lit.site.cfg to test on VE
sed -e 's:test_openmp_flags = ":test_openmp_flags = "-target ve-linux -frtlib-add-rpath -ldl :' \
    -i runtime/test/lit.site.cfg

# Add -j1 to llvm-lit
sed -e 's:llvm-lit:llvm-lit -j1:' \
    -i build.ninja
