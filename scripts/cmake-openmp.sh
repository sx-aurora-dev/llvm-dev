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
  -DLLVM_DIR="$DEST/lib/cmake/llvm" \
  -DZLIB_LIBRARY="/lib/x86_64-linux-gnu/" \
  -DCMAKE_SKIP_RPATH=true \
  $SRCDIR/openmp

# Modify lit.site.cfg to test on VE
sed -e 's:test_openmp_flags = ":test_openmp_flags = "-target ve-linux -frtlib-add-rpath -ldl -lrt :' \
    -i runtime/test/lit.site.cfg

# Add -j1 to llvm-lit
sed -e 's:llvm-lit:llvm-lit -j1:' \
    -i build.ninja

# Fix include problem caused by f2f88f3
# It tries to read header files for host.
sed -e 's:-isystem /usr/include::' \
    -i build.ninja

# Fix library target problem caused by f2f88f3
# It tries to link library files for host.
sed -e 's:\(build libomptarget/libomptarget.so.*\) |.*$:\1:' \
    -i build.ninja

# Fix link library problem caused by f2f88f3
# It tries to link library files for host.
sed -e 's:LINK_LIBRARIES = .*/libLLVMSupport.a.*\(-ldl *-Wl,--version-script=.*/exports\).*:LINK_LIBRARIES = \1:' \
    -i build.ninja
