#! /bin/sh

REPO=$1
shift

if test x$REPO = x; then
        REPO=$(cd `dirname $0` && git config remote.origin.url | sed 's%/llvm-dev.git%%')
fi

SRCDIR=$(readlink -f ${SRCDIR:=src})

echo REPO=${REPO}
echo SRCDIR=$SRCDIR

export REPO
export SRCDIR

mkdir -p ${SRCDIR}

make -f llvm-dev/Makefile shallow
