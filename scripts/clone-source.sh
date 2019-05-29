#!/bin/sh

RAWOPT="$@"


# Check target $REPO and remove trailing '/' from $REPO
case x"$REPO" in
x) echo Please specify target repository by REPO environment variable
   exit 1;;
*) ;;
esac
REPO=`echo $REPO | sed -e 's:/$::'`

# Check target $BRANCH and add it to $OPT if it exists
OPT=${RAWOPT}
case x"$BRANCH" in
x) ;;
*) OPT="-b $BRANCH $RAWOPT";;
esac

mkdir -p $SRCDIR
cd $SRCDIR

test -d llvm || git clone $CDLREPO/llvm-aurora-dev.git llvm -b develop_cdl $RAWOPT
test -d llvm/tools/rv || git clone $CDLREPO/rv.git llvm/tools/rv -b develop_vp $RAWOPT
(cd llvm/tools/rv && git submodule update --init --recursive)

test -d llvm/tools/clang || git clone $REPO/clang.git llvm/tools/clang $OPT
test -d llvm/projects/libcxx || \
  git clone $REPO/libcxx.git llvm/projects/libcxx $OPT
test -d llvm/projects/libcxxabi || \
  git clone $REPO/libcxxabi.git llvm/projects/libcxxabi $OPT
test -d llvm/projects/compiler-rt || \
  git clone $REPO/compiler-rt.git llvm/projects/compiler-rt $OPT
test -d llvm/projects/libunwind || \
  git clone $REPO/libunwind.git llvm/projects/libunwind $OPT
test -d llvm/projects/openmp || \
  git clone $REPO/openmp.git llvm/projects/openmp $OPT

