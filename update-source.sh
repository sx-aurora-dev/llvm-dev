#!/bin/sh

OPT="$@"

# Add -u option (update-head-ok) to update current branch
OPT="-u $OPT"

# Need -f option (force) for the case of shallow clone
FOPT=""
case "$OPT" in
*"--depth 1") FOPT="-f";;
*) ;;
esac

# Set default branch if $BRANCH is not defined
case x"$BRANCH" in
x) BRANCH=develop;;
*) ;;
esac

function update() {
  # 1. Fetch target $BRANCH
  # 2. Changed local $BRANCH to specify remote $BRANCH
  #    - This shows errors if local $BRANCH is not ok to fast-forward rebase
  git fetch origin $OPT && \
    git fetch origin $BRANCH:$BRANCH $OPT $FOPT

  # 3. Change current branch to $BRANCH if current branch is not dirty
  #    - -f is required since doing check out from previous $BRANCH to
  #      updated latest $BRANCH
  case x`git diff-index --name-only HEAD | tail -n1` in
  x) git checkout $BRANCH -f;;
  *) echo Modified source code is in `pwd`.  Please commit or stash them.
     exit 1;;
  esac
}

TOP=`pwd`
cd $TOP/llvm; update
cd $TOP/llvm/tools/clang; update
cd $TOP/llvm/projects/libcxx; update
cd $TOP/llvm/projects/libcxxabi; update
cd $TOP/llvm/projects/compiler-rt; update
cd $TOP/llvm/projects/libunwind; update
cd $TOP/llvm/projects/openmp; update
cd $TOP/ve-csu; update
