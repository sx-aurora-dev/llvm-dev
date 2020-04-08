#!/bin/sh

OPT="$@"

# Check target $REPO and remove trailing '/' from $REPO
case x"$REPO" in
x) echo Please specify target repository by REPO environment variable
   exit 1;;
*) ;;
esac
REPO=`echo $REPO | sed -e 's:/$::'`

# Check target $BRANCH and add it to $OPT if it exists
case x"$BRANCH" in
x) ;;
*) OPT="-b $BRANCH $OPT";;
esac

test -d llvm-project || git clone $REPO/llvm-project.git $SRCDIR  $OPT
