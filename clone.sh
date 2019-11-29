#!/usr/bin/env bash

LLVM_DEV_DIR=$(dirname $(readlink -f $0))
REPOS=$1
BRANCH=$2

if test x$BRANCH = x; then
        BRANCH=hpce/develop
	echo "no BRANCH provided.. defaulting to ${BRANCH}"
fi

if test x$REPOS = x; then
	echo "no repository root provided.. aborting!"
	return;
fi

SRCDIR=$(readlink -f ${SRCDIR:=src})


echo BRANCH=${BRANCH}
echo REPOS=${REPOS}
echo SRCDIR=$SRCDIR
echo LLVM_DEV_DIR=${LLVM_DEV_DIR}

make -f ${LLVM_DEV_DIR}/Makefile deep REPOS=$REPOS SRCDIR=$SRCDIR BRANCH=$BRANCH
