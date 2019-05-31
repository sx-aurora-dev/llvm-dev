#!/bin/bash

REPO=$1
shift

if test x$REPO = x; then
        REPO=$(dirname $(cd `dirname $0` && git config remote.origin.url))
fi

SRCDIR=$(readlink -f ${SRCDIR:=src})

LLVM_DEV_DIR=$(dirname $(readlink -f $0))

echo REPO=${REPO}
echo SRCDIR=$SRCDIR

make -f $LLVM_DEV_DIR/Makefile shallow REPO=$REPO SRCDIR=$SRCDIR
