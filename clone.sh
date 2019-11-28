#!/usr/bin/env bash

LLVM_DEV_DIR=$(dirname $(readlink -f $0))
REPO=$1
BRANCH=$2

if test x$BRANCH = x; then
        BRANCH=hpce/develop
	echo "no BRANCH provided.. defaulting to ${BRANCH}"
fi

if test x$REPO = x; then
        REPO=$(dirname $(cd `dirname $0` && git config remote.origin.url))
	echo "no repository provided.. defaulting to ${REPO}"
fi

SRCDIR=$(readlink -f ${SRCDIR:=src})


echo BRANCH=${BRANCH}
echo REPO=${REPO}
echo SRCDIR=$SRCDIR
echo LLVM_DEV_DIR=${LLVM_DEV_DIR}

make -f ${LLVM_DEV_DIR}/Makefile deep REPO=$REPO SRCDIR=$SRCDIR BRANCH=$BRANCH
