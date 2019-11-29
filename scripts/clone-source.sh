#!/bin/sh

OPT="$@"

# Check target $REPO and remove trailing '/' from $REPO
case x"$REPOS" in
x) echo Please specify target repository by REPOS environment variable
   exit 1;;
*) ;;
esac
REPOS=`echo $REPOS | sed -e 's:/$::'`

# Check target $BRANCH and add it to $OPT if it exists
case x"$BRANCH" in
x) ;;
*) OPT="-b $BRANCH $OPT";;
esac

mkdir -p $SRCDIR
cd $SRCDIR

test -d llvm-project || git clone --recurse-submodules ${REPOS}/llvm-project.git llvm-project ${OPT}
test -d llvm-project/llvm/tools/rv || git clone --recurse-submodules ${REPOS}/rv.git llvm-project/llvm/tools/rv ${OPT}
