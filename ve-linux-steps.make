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
	@echo "build-runtimes-ve"
	@echo "install-runtimes-ve"
	@echo "build-omp-ve"
	@echo "install-omp-ve"

install:
	${SELFMAKE} prepare
	${SELFMAKE} build-llvm
	${SELFMAKE} install-llvm
	${SELFMAKE} build-crt-ve
	${SELFMAKE} install-crt-ve
	${SELFMAKE} build-runtimes-ve
	${SELFMAKE} install-runtimes-ve
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
RUNTIMES_BUILD_VE="${BUILDROOT}/build_runtimes_ve"
OMP_BUILD_VE="${BUILDROOT}/build_omp_ve"

# Install prefix structure
BUILT_CLANG="${PREFIX}/bin/clang"
BUILT_CLANGXX="${PREFIX}/bin/clang++"
X86_TRIPLE=x86_64-unknown-linux-gnu
VE_TRIPLE=ve-unknown-linux-gnu

# Resource dir (Requires clang to be installed before this variable gets expanded)
RES_VERSION=$(shell ${LLVM_BUILD}/bin/llvm-config  --version | sed -n 's/git//p')
CLANG_RESDIR="${PREFIX}/lib/clang/${RES_VERSION}"

### LLVM
# DWARF symbol issues with dylib, atm (defaulting to static build).
LLVM_BUILD_DYLIB?=On
# Whether to build separate shared libraries per component.
LLVM_BUILD_SOLIBS?=Off
LLVM_BUILD_TYPE?=Release

CRT_BUILD_TYPE?=Release
CRT_OPTFLAGS?=-O2
CRT_TEST_OPTFLAGS?=-O2

### Runtimes config
RUNTIMES_BUILD_TYPE?=Release
RUNTIMES_OPTFLAGS?=-O2

## openmp
OMP_BUILD_TYPE?=Release
OMP_OPTFLAGS?=-O2



##### Build Steps #####

### Vanilla LLVM stage ###
build-llvm:
	mkdir -p ${LLVM_BUILD}
	cd ${LLVM_BUILD} && ${CMAKE} ${MONOREPO}/llvm -G Ninja \
	      -DCMAKE_BUILD_TYPE=${LLVM_BUILD_TYPE} \
	      -DLLVM_PARALLEL_LINK_JOBS=1 \
              -DBUILD_SHARED_LIBS=${LLVM_BUILD_SOLIBS} \
	      -DLLVM_BUILD_LLVM_DYLIB=${LLVM_BUILD_DYLIB} \
	      -DLLVM_LINK_LLVM_DYLIB=${LLVM_BUILD_DYLIB} \
	      -DCLANG_LINK_CLANG_DYLIB=${LLVM_BUILD_DYLIB} \
              \
	      -DLLVM_TARGETS_TO_BUILD="X86;VE" \
	      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
              \
	      -DLLVM_ENABLE_PROJECTS="clang;compiler-rt" \
	      -DLLVM_INSTALL_UTILS=On \
              \
	      -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;openmp" \
              -DLLVM_RUNTIME_TARGETS="${X86_TRIPLE}" \
              -DRUNTIMES_x86_64-unknown-linux-gnu_OPENMP_STANDALONE_BUILD=ON \
              -DRUNTIMES_x86_64-unknown-linux-gnu_OPENMP_LIBDIR_SUFFIX="/${X86_TRIPLE}" \
              -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON
	cd ${LLVM_BUILD} && ${NINJA} ${JOB_LIMIT_FLAG}

install-llvm:
	cd ${LLVM_BUILD} && ${NINJA} install

check-llvm:
	cd ${LLVM_BUILD} && ${NINJA} check-all


### Compiler-RT standalone ###

build-crt-ve:
	mkdir -p ${CRT_BUILD_VE}
	cd ${CRT_BUILD_VE} && ${CMAKE} ${MONOREPO}/runtimes -G Ninja \
              -DCMAKE_BUILD_TYPE=${CRT_BUILD_TYPE} \
	      -DCMAKE_C_COMPILER=${BUILT_CLANG} \
	      -DCMAKE_C_COMPILER_TARGET=${VE_TRIPLE} \
	      -DCMAKE_CXX_COMPILER=${BUILT_CLANGXX} \
	      -DCMAKE_CXX_COMPILER_TARGET=${VE_TRIPLE} \
	      -DCMAKE_ASM_COMPILER_TARGET=${VE_TRIPLE} \
	      -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	      -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
              -DCMAKE_C_COMPILER_TARGET=${VE_TRIPLE} \
              -DCMAKE_CXX_COMPILER_TARGET=${VE_TRIPLE} \
              -DCMAKE_ASM_COMPILER_TARGET=${VE_TRIPLE} \
              -DCMAKE_INSTALL_PREFIX=${CLANG_RESDIR} \
              -DCMAKE_CXX_FLAGS="-nostdlib" \
              -DCMAKE_CXX_FLAGS_RELEASE="${CRT_OPTFLAGS}" \
              -DCMAKE_C_FLAGS="-nostdlib" \
              -DCMAKE_C_FLAGS_RELEASE="${CRT_OPTFLAGS}" \
              -DBUILD_SHARED_LIBS=ON \
              -DLLVM_CONFIG_PATH=${LLVM_BUILD}/bin/llvm-config \
              -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
              -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
              -DCOMPILER_RT_BUILD_BUILTINS=ON \
              -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
              -DCOMPILER_RT_BUILD_XRAY=OFF \
              -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
              -DCOMPILER_RT_BUILD_PROFILE=ON \
              -DCOMPILER_RT_INCLUDE_TESTS=ON \
              -DCOMPILER_RT_TEST_COMPILER=${PREFIX}/bin/clang \
              -DCOMPILER_RT_TEST_COMPILER_CFLAGS="-target $${VE_TRIPLE} ${CRT_TEST_OPTFLAGS}" \
              -DLLVM_ENABLE_RUNTIMES="compiler-rt"
	cd ${CRT_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}

check-crt-ve: build-crt-ve
	cd ${CRT_BUILD_VE} && env PATH=${PREFIX}/bin:${PATH} ${NINJA} check-compiler-rt

install-crt-ve: build-crt-ve
	cd ${CRT_BUILD_VE} && ${NINJA} install


### runtimes standalone ###
build-runtimes-ve:
	mkdir -p ${RUNTIMES_BUILD_VE}
	cd ${RUNTIMES_BUILD_VE} && ${CMAKE} ${MONOREPO}/runtimes -G Ninja \
            -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
            -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
            -DLLVM_DEFAULT_TARGET_TRIPLE=${VE_TRIPLE} \
            -DLLVM_CONFIG_PATH=${PREFIX}/bin/llvm-config \
            \
	    -DCMAKE_C_COMPILER=${BUILT_CLANG} \
	    -DCMAKE_CXX_COMPILER=${BUILT_CLANGXX} \
	    -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	    -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
	    -DCMAKE_C_COMPILER_TARGET=${VE_TRIPLE} \
	    -DCMAKE_CXX_COMPILER_TARGET=${VE_TRIPLE} \
	    -DCMAKE_BUILD_TYPE=${RUNTIMES_BUILD_TYPE} \
	    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	    -DCMAKE_CXX_FLAGS="-nostdlib++" \
	    -DCMAKE_CXX_FLAGS_RELEASE="${RUNTIMES_OPTFLAGS}" \
	    -DCMAKE_C_FLAGS_RELEASE="${RUNTIMES_OPTFLAGS}" \
            \
	    -DLIBCXX_USE_COMPILER_RT=True \
  	    -DLIBCXX_TARGET_TRIPLE=${VE_TRIPLE} \
  	    -DLIBCXX_CXX_ABI=libcxxabi \
  	    -DLIBCXX_CXX_ABI_INCLUDE_PATHS=${MONOREPO}/libcxxabi/include \
  	    -DLIBCXX_INCLUDE_BENCHMARKS=Off \
            \
  	    -DLIBCXXABI_USE_LLVM_UNWINDER=True
	cd ${RUNTIMES_BUILD_VE} && ${NINJA} ${JOB_LIMIT_FLAG}

install-runtimes-ve:
	cd ${RUNTIMES_BUILD_VE} && ${NINJA} install

### OpenMP for VE ###
        
build-omp-ve:
	mkdir -p ${OMP_BUILD_VE}
	cd ${OMP_BUILD_VE} && ${CMAKE} ${MONOREPO}/openmp -G Ninja \
	      -DCMAKE_C_COMPILER=${PREFIX}/bin/clang \
	      -DCMAKE_CXX_COMPILER=${PREFIX}/bin/clang++ \
	      -DCMAKE_AR=${PREFIX}/bin/llvm-ar \
	      -DCMAKE_RANLIB=${PREFIX}/bin/llvm-ranlib \
	      -DCMAKE_C_COMPILER_TARGET=${VE_TRIPLE} \
	      -DCMAKE_CXX_COMPILER_TARGET=${VE_TRIPLE} \
	      -DCMAKE_BUILD_TYPE=${OMP_BUILD_TYPE} \
	      -DCMAKE_INSTALL_PREFIX=${CLANG_RESDIR} \
	      -DCMAKE_CXX_FLAGS_RELEASE="${OMP_OPTFLAGS}" \
	      -DCMAKE_C_FLAGS_RELEASE="${OMP_OPTFLAGS}" \
	      -DLLVM_DIR="${PREFIX}/lib/cmake/llvm" \
              \
	      -DOPENMP_LIBDIR_SUFFIX="/${VE_TRIPLE}" \
	      -DOPENMP_LLVM_TOOLS_DIR=${LLVM_BUILD}/bin \
              -DOPENMP_ENABLE_LIBOMPTARGET_PROFILING=OFF \
              -DLIBOMP_HAVE_SHM_OPEN_WITH_LRT=ON 
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
