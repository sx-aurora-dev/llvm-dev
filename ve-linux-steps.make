##### Interface Variables & Targets #####
BUILDROOT?=$(error "BUILDROOT has to be the path to the worker's build/ directory.")
MONOREPO?=${BUILDROOT}/../llvm-project
PREFIX?="${BUILDROOT}/install"

THISMAKE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))

SELFMAKE=make -f ${THISMAKE_PATH}

# Renders one target per line in make order.  Each target will made with a
# build step with the 'get-steps' annotated builder (ve-linux.py).
get-steps:
	@echo "prepare"
	@echo "build-llvm"
	@echo "check-llvm"
	@echo "build-crt-ve"
	@echo "install-crt-ve"
	@echo "check-crt-ve"
	@echo "build-libunwind-ve"
	@echo "install-libunwind-ve"
	@echo "build-libcxxabi-ve"
	@echo "install-libcxxabi-ve"
	@echo "build-libcxx-ve"
	@echo "install-libcxx-ve"
	@echo "build-omp-ve"
	@echo "install-omp-ve"

install:
	${SELFMAKE} prepare
	${SELFMAKE} build-llvm
	${SELFMAKE} install-llvm
	${SELFMAKE} build-crt-ve
	${SELFMAKE} install-crt-ve
	${SELFMAKE} build-libunwind-ve
	${SELFMAKE} install-libunwind-ve
	${SELFMAKE} build-libcxxabi-ve
	${SELFMAKE} install-libcxxabi-ve
	${SELFMAKE} build-libcxx-ve
	${SELFMAKE} install-libcxx-ve
	${SELFMAKE} build-omp-ve
	${SELFMAKE} install-omp-ve

##### Tools & Config #####
CMAKE?=cmake
NINJA?=ninja

# Maximum number of ${NINJA} jobs (builds only)
# JOB_LIMIT_FLAG=-j3
JOB_LIMIT_FLAG?=

##### Derived Configuration #####

# Path

# Build foders
LLVM_BUILD="${BUILDROOT}/build_llvm"
CRT_BUILD_VE="${BUILDROOT}/build_crt_ve"
LIBUNWIND_BUILD_VE="${BUILDROOT}/build_libunwind_ve"
LIBCXXABI_BUILD_VE="${BUILDROOT}/build_libcxxabi_ve"
LIBCXX_BUILD_VE="${BUILDROOT}/build_libcxx_ve"
OMP_BUILD_VE="${BUILDROOT}/build_omp_ve"

# Install prefix structure
BUILT_CLANG="${PREFIX}/bin/clang"
BUILT_CLANGXX="${PREFIX}/bin/clang++"
VE_TARGET=ve-linux
LINUX_VE_LIBSUFFIX=/linux/ve

# Resource dir (Requires clang to be installed before this variable gets expanded)
RES_VERSION=$(shell ${LLVM_BUILD}/bin/llvm-config  --version | sed -n 's/git//p')
CLANG_RESDIR="${PREFIX}/lib/clang/${RES_VERSION}"

### LLVM
# DWARF symbol issues with dylib, atm (defaulting to static build).
LLVM_BUILD_DYLIB?=Off
# Whether to build separate shared libraries per component.
LLVM_BUILD_SOLIBS?=On
LLVM_BUILD_TYPE?=RelWithDebInfo
RUNTIMES_BUILD_TYPE?=Release

### Compiler-RT
CRT_BUILD_TYPE?=${RUNTIMES_BUILD_TYPE}
CRT_OPTFLAGS=-O2

## libunwind
LIBUNWIND_BUILD_TYPE?=${RUNTIMES_BUILD_TYPE}
LIBUNWIND_OPTFLAGS?=-O2

## libcxxabi
LIBCXXABI_BUILD_TYPE?=${RUNTIMES_BUILD_TYPE}
LIBCXXABI_OPTFLAGS?=-O2

## libcxxabi
LIBCXX_BUILD_TYPE?=${RUNTIMES_BUILD_TYPE}
LIBCXX_OPTFLAGS?=-O2

## openmp
OMP_BUILD_TYPE?=${RUNTIMES_BUILD_TYPE}
OMP_OPTFLAGS?=-O2




##### Build Steps #####

### Vanilla LLVM stage ###
build-llvm:
	mkdir -p ${LLVM_BUILD}
	cd ${LLVM_BUILD} && ${CMAKE} ${MONOREPO}/llvm -G Ninja \
	      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	      -DLLVM_PARALLEL_LINK_JOBS=1 \
              -DBUILD_SHARED_LIBS=${LLVM_BUILD_SOLIBS} \
	      -DLLVM_BUILD_LLVM_DYLIB=${LLVM_BUILD_DYLIB} \
	      -DLLVM_LINK_LLVM_DYLIB=${LLVM_BUILD_DYLIB} \
	      -DCLANG_LINK_CLANG_DYLIB=${LLVM_BUILD_DYLIB} \
	      -DLLVM_TARGETS_TO_BUILD="X86" \
	      -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="VE" \
	      -DLLVM_ENABLE_PROJECTS="clang" \
	      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	      -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;openmp" \
	      -DLLVM_INSTALL_UTILS=On
	cd ${LLVM_BUILD} && ${NINJA} ${JOB_LIMIT_FLAG}

install-llvm:
	# build-llvm
	cd ${LLVM_BUILD} && ${NINJA} install
	# Manually move libc++ headers to $RESDIR
	mkdir -p ${CLANG_RESDIR}/include
	cp -r "${PREFIX}/include/c++" "${CLANG_RESDIR}/include/"

check-llvm:
	# build-llvm
	cd ${LLVM_BUILD} && ${NINJA} check-all


### Compiler-RT standalone ###

build-crt-ve:
	mkdir -p ${CRT_BUILD_VE}
	cd ${CRT_BUILD_VE} && ${CMAKE} ${MONOREPO}/compiler-rt -G Ninja \
	    -DCOMPILER_RT_BUILD_BUILTINS=ON \
	    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	    -DCOMPILER_RT_BUILD_XRAY=OFF \
	    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	    -DCOMPILER_RT_BUILD_PROFILE=ON \
	    -DBUILD_SHARED_LIBS=ON \
	    -DCMAKE_C_COMPILER=${BUILT_CLANG} \
	    -DCMAKE_C_COMPILER_TARGET=${VE_TARGET} \
	    -DCMAKE_CXX_COMPILER=${BUILT_CLANGXX} \
	    -DCMAKE_CXX_COMPILER_TARGET=${VE_TARGET} \
	    -DCMAKE_ASM_COMPILER_TARGET=${VE_TARGET} \
	    -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	    -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
	    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	    -DLLVM_CONFIG_PATH=${PREFIX}/bin/llvm-config \
	    -DCMAKE_BUILD_TYPE=${CRT_BUILD_TYPE} \
	    -DCMAKE_INSTALL_PREFIX=${CLANG_RESDIR} \
	    -DCMAKE_CXX_FLAGS=-nostdlib \
	    -DCMAKE_CXX_FLAGS_RELEASE=${CRT_OPTFLAGS} \
	    -DCMAKE_C_FLAGS=-nostdlib \
	    -DCMAKE_C_FLAGS_RELEASE=${CRT_OPTFLAGS} \
	    -DCOMPILER_RT_INCLUDE_TESTS=ON \
	    -DCOMPILER_RT_TEST_COMPILER=${BUILT_CLANG} \
	    -DCOMPILER_RT_TEST_COMPILER_CFLAGS="--target=${VE_TARGET}"
	cd ${CRT_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}

check-crt-ve: build-crt-ve
	cd ${CRT_BUILD_VE} && env PATH=${PREFIX}/bin:${PATH} ${NINJA} check-compiler-rt

install-crt-ve: build-crt-ve
	cd ${CRT_BUILD_VE} && ${NINJA} install


### libunwind standalone ###
build-libunwind-ve:
	mkdir -p ${LIBUNWIND_BUILD_VE}
	cd ${LIBUNWIND_BUILD_VE} && ${CMAKE} ${MONOREPO}/libunwind -G Ninja \
	    -DLIBUNWIND_TARGET_TRIPLE="${VE_TARGET}" \
	    -DCMAKE_C_COMPILER=${BUILT_CLANG} \
	    -DCMAKE_CXX_COMPILER=${BUILT_CLANGXX} \
	    -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	    -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
	    -DCMAKE_C_COMPILER_TARGET="${VE_TARGET}" \
	    -DCMAKE_CXX_COMPILER_TARGET="${VE_TARGET}" \
	    -DCMAKE_BUILD_TYPE="${LIBUNWIND_BUILD_TYPE}" \
	    -DCMAKE_INSTALL_PREFIX="${CLANG_RESDIR}" \
	    -DLIBUNWIND_LIBDIR_SUFFIX="${LINUX_VE_LIBSUFFIX}" \
	    -DCMAKE_CXX_FLAGS="-nostdlib" \
	    -DCMAKE_CXX_FLAGS_RELEASE="${LIBUNWIND_OPTFLAGS}" \
	    -DCMAKE_C_FLAGS="-nostdlib" \
	    -DCMAKE_C_FLAGS_RELEASE="${LIBUNWIND_OPTFLAGS}" \
	    -DLIBUNWIND_LIBCXX_PATH=${MONOREPO}/libcxx \
	    -DLLVM_PATH=${MONOREPO}/llvm
	cd ${LIBUNWIND_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}

install-libunwind-ve:
	cd ${LIBUNWIND_BUILD_VE} && ${NINJA} install


### libcxx standalone ###

build-libcxx-ve:
	mkdir -p ${LIBCXX_BUILD_VE}
	cd ${LIBCXX_BUILD_VE} && ${CMAKE} ${MONOREPO}/libcxx -G Ninja \
	        -DLIBCXX_USE_COMPILER_RT=True \
  	        -DLIBCXX_TARGET_TRIPLE="${VE_TARGET}" \
  	        -DCMAKE_C_COMPILER=${BUILT_CLANG} \
  	        -DCMAKE_CXX_COMPILER=${BUILT_CLANGXX} \
  	        -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
  	        -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
  	        -DCMAKE_C_COMPILER_TARGET="${VE_TARGET}" \
  	        -DCMAKE_CXX_COMPILER_TARGET="${VE_TARGET}" \
  	        -DCMAKE_BUILD_TYPE="${LIBCXX_BUILD_TYPE}" \
  	        -DCMAKE_INSTALL_PREFIX="${CLANG_RESDIR}" \
  	        -DLIBCXX_LIBDIR_SUFFIX="${LINUX_VE_LIBSUFFIX}" \
  	        -DLIBCXXABI_USE_LLVM_UNWINDER=True \
  	        -DLIBCXX_CXX_ABI=libcxxabi \
  	        -DLIBCXX_CXX_ABI_INCLUDE_PATHS=${MONOREPO}/libcxxabi/include \
  	        -DLIBCXX_INCLUDE_BENCHMARKS=Off \
  	        -DCMAKE_C_FLAGS_RELEASE="${LIBCXX_OPTFLAGS}" \
  	        -DCMAKE_CXX_FLAGS="-nostdlib++" \
  	        -DCMAKE_CXX_FLAGS_RELEASE="${LIBCXX_OPTFLAGS}" \
  	        -DLIBCXX_USE_COMPILER_RT=True
	cd ${LIBCXX_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}

check-libcxx-ve:
	cd ${LIBCXX_BUILD_VE} && ${NINJA} check-cxx

install-libcxx-ve:
	cd ${LIBCXX_BUILD_VE} && ${NINJA} install
        



### libcxxabi standalone ###

build-libcxxabi-ve:
	mkdir -p ${LIBCXXABI_BUILD_VE}
	cd ${LIBCXXABI_BUILD_VE} && ${CMAKE} ${MONOREPO}/libcxxabi -G Ninja \
	      -DCMAKE_C_COMPILER=${BUILT_CLANG} \
	      -DCMAKE_CXX_COMPILER=${BUILT_CLANGXX} \
	      -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	      -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
	      -DCMAKE_C_COMPILER_TARGET="${VE_TARGET}" \
	      -DCMAKE_CXX_COMPILER_TARGET="${VE_TARGET}" \
	      -DLLVM_CONFIG_PATH=${PREFIX}/bin/llvm-config \
	      -DCMAKE_BUILD_TYPE="${LIBCXXABI_BUILD_TYPE}" \
	      -DCMAKE_INSTALL_PREFIX="${CLANG_RESDIR}" \
	      -DLIBCXXABI_LIBDIR_SUFFIX="${LINUX_VE_LIBSUFFIX}" \
	      -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
	      -DCMAKE_CXX_FLAGS="-nostdlib++" \
	      -DCMAKE_CXX_FLAGS_RELEASE="${LIBCXX_OPTFLAGS}" \
	      -DCMAKE_C_FLAGS_RELEASE="${LIBCXX_OPTFLAGS}" \
	      -DLLVM_PATH=${MONOREPO}/llvm \
	      -DLLVM_MAIN_SRC_DIR=${MONOREPO}/llvm \
	      -DLIBCXXABI_USE_COMPILER_RT=True \
	      -DLIBCXXABI_HAS_NOSTDINCXX_FLAG=True \
	      -DLIBCXXABI_LIBCXX_INCLUDES="${CLANG_RESDIR}/include/c++/v1/"
	cd ${LIBCXXABI_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}
        
check-libcxxabi-ve:
	cd ${LIBCXXABI_BUILD_VE} && ${NINJA} check-cxxabi

install-libcxxabi-ve:
	cd ${LIBCXXABI_BUILD_VE} && ${NINJA} install
        
build-omp-ve:
	mkdir -p ${OMP_BUILD_VE}
	cd ${OMP_BUILD_VE} && ${CMAKE} ${MONOREPO}/openmp -G Ninja \
	      -DCMAKE_C_COMPILER=${BUILT_CLANG} \
	      -DCMAKE_C_COMPILER=${PREFIX}/bin/clang \
	      -DCMAKE_CXX_COMPILER=${PREFIX}/bin/clang++ \
	      -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	      -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
	      -DCMAKE_C_COMPILER_TARGET="${VE_TARGET}" \
	      -DCMAKE_CXX_COMPILER_TARGET="${VE_TARGET}" \
	      -DCMAKE_BUILD_TYPE="${OMP_BUILD_TYPE}" \
	      -DCMAKE_INSTALL_PREFIX="${CLANG_RESDIR}" \
	      -DOPENMP_LIBDIR_SUFFIX="${LINUX_VE_LIBSUFFIX}" \
	      -DCMAKE_CXX_FLAGS="" \
	      -DCMAKE_CXX_FLAGS_RELEASE="${OMP_OPTFLAGS}" \
	      -DCMAKE_C_FLAGS="" \
	      -DCMAKE_C_FLAGS_RELEASE="${OMP_OPTFLAGS}" \
	      -DLIBOMP_ARCH=ve \
	      -DOPENMP_LLVM_TOOLS_DIR=$TOOLDIR \
	      -DLLVM_DIR="${PREFIX}/lib/${CMAKE}/llvm" \
	      -DZLIB_LIBRARY="/lib/x86_64-linux-gnu/" \
	      -DCMAKE_SKIP_RPATH=true
	cd ${OMP_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}

install-omp-ve:
	cd ${OMP_BUILD_VE} && ${NINJA} install


# Clearout the temporary install prefix.
prepare:
	rm -f ${PREFIX}/lib/\*
	rm -rf ${PREFIX}/bin/*
	rm -rf ${PREFIX}/include/*

purge:
	rm -rf ${PREFIX}/install
	rm -rf ${BUILDROOT}/build\*

.PHONY: get-steps install
