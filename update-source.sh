#!/bin/sh

OPT="$@"

# Add -u option (update-head-ok) to update current branch
OPT="-u $OPT"

# Add -f option (force) for the case of shallow fetch
COOPT=""
case "$OPT" in
*"--depth 1") OPT="-f $OPT"; COOPT="-f";;
*) ;;
esac

# Set default branch if $BRANCH is not defined
case x"$BRANCH" in
x) BRANCH=develop;;
*) ;;
esac

TOP=`pwd`
cd $TOP/llvm
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/llvm/tools/clang
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/llvm/projects/libcxx
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/llvm/projects/libcxxabi
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/llvm/projects/compiler-rt
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/llvm/projects/libunwind
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/llvm/projects/openmp
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
cd $TOP/ve-csu
git fetch origin $BRANCH:$BRANCH $OPT && git co $BRANCH $COOPT
