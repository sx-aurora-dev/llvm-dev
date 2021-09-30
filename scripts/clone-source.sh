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

cd ${WSPACE}
test -d llvm-project || git clone --recurse-submodules ${REPOS}/llvm-project.git llvm-project ${OPT}
# RV is a proper submodule now.
#test -d llvm-project/llvm/lib/rv || git clone --recurse-submodules ${REPOS}/rv.git llvm-project/llvm/lib/rv ${OPT}
