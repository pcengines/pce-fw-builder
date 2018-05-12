#!/bin/bash

cd /home/coreboot/coreboot

legacy=$1
shift

if [ $# == 1 ];then
    echo "Build coreboot for $1"
    make distclean
    cp configs/pcengines_$1.config .config
    make -j$(nproc)
elif [ $# == 2 ]; then
    echo "Build custom coreboot for $1"
    # remove platform
    shift
    make $*
else
    echo "ERROR: invalid arguments $*"
fi

