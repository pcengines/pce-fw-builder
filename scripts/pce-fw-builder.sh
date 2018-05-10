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
    if [ "$2" == "nodistclean" ]; then
        make -j$(nproc)
    else
        echo "distclean"
        make distclean
        echo "copy $1 config"
        cp configs/pcengines_$1.config .config
        # remove platform version
        shift
        make -j$(nproc) $1
        make -j$(nproc)
    fi
else
    echo "ERROR: invalid arguments $*"
fi

