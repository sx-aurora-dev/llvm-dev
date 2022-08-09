#!/bin/sh

$CMAKE -G Ninja \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DCMAKE_C_COMPILER=$DEST/bin/clang \
  -DCMAKE_CXX_COMPILER=$DEST/bin/clang++ \
  -DCMAKE_AR=$DEST/bin/llvm-ar \
  -DCMAKE_RANLIB=$DEST/bin/llvm-ranlib \
  -DCMAKE_C_COMPILER_TARGET=$TARGET \
  -DCMAKE_CXX_COMPILER_TARGET=$TARGET \
  -DCMAKE_INSTALL_PREFIX=$DEST \
  -DCMAKE_CXX_FLAGS_RELEASE="$OPTFLAGS" \
  -DCMAKE_C_FLAGS_RELEASE="$OPTFLAGS" \
  -DLLVM_DIR="$DEST/lib/cmake/llvm" \
  -DOPENMP_LIBDIR_SUFFIX="/$TARGET" \
  -DOPENMP_LLVM_TOOLS_DIR=$TOOLDIR \
  -DOPENMP_ENABLE_LIBOMPTARGET_PROFILING=OFF \
  -DLIBOMP_HAVE_SHM_OPEN_WITH_LRT=ON \
  $SRCDIR/openmp

# Disable TERMINFO and ZLIB since those are enabled by default and cause
# compile error in libomptarget.  I believe the source of problem is
# libomptarget since accelarator never requires terminfo.

# Modify lit.site.cfg to test on VE
#sed -e 's:test_openmp_flags = ":test_openmp_flags = "-target ve-linux -frtlib-add-rpath -ldl -lrt :' \
#    -i runtime/test/lit.site.cfg

# Add -j1 to llvm-lit
sed -e 's:llvm-lit:llvm-lit -j1:' \
    -i build.ninja
