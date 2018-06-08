#!/bin/bash

cd /home/coreboot/coreboot

legacy=$1
shift

if [ $# == 1 ];then
    echo "Build coreboot for $1"
    make distclean
    if [ -f configs/config.pcengines_$1 ]; then
        cp configs/config.pcengines_$1 .config && make olddefconfig
    elif [ -f configs/pcengines_$1.config ]; then
        cp configs/pcengines_$1.config .config
    else
        echo "ERROR: no configuration exist for $*"
    fi
    make
elif [ $# == 2 ]; then
    echo "Build custom coreboot for $1"
    # remove platform
    shift
    make $*
else
    echo "ERROR: invalid arguments $*"
fi

