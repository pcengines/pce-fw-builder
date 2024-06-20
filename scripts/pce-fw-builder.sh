#!/bin/bash

export PATH="/usr/lib/ccache:$PATH"
ccache -s
cd /home/coreboot/coreboot

legacy=$1
sslverify=$2
shift 2

if [ $# == 1 ];then
    echo "Build coreboot for $1"
    make distclean
    git config --global http.sslVerify $sslverify
    if [ -f configs/config.pcengines_$1 ]; then
        cp configs/config.pcengines_$1 .config && make olddefconfig
    elif [ -f configs/pcengines_$1.config ]; then
        cp configs/pcengines_$1.config .config
    else
        echo "ERROR: no configuration exist for $*"
    fi
    make BUILD_TIMELESS=1
elif [ $# == 2 ]; then
    echo "Build custom coreboot for $1"
    # remove platform
    shift
    make BUILD_TIMELESS=1 $*
else
    echo "ERROR: invalid arguments $*"
fi

