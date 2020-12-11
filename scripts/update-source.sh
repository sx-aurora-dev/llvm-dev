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
  git fetch origin $OPT

  # 2. Changed current branch to $BRANCH
  #    - This shows errors if local $BRANCH has conflicts
  git checkout $BRANCH

  # 3. Change current branch to $BRANCH if current branch is not dirty
  id=`git describe --always --abbrev=0 --match "NOT A TAG" --dirty="-dirty"`
  case $id in
  *-dirty)
    echo Modified source code is in `pwd`.
    echo Please commit or stash them.
    exit 1;;
  esac
  git reset --hard origin/$BRANCH
}

cd ${WSPACE}/llvm-project; update
cd ${WSPACE}/llvm-project/llvm/tools/rv; update
