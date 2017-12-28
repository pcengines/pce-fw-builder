#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: ./build.sh <tag|branch> <platform> [<menuconfig-param>]"
    echo "  <tag|branch> - tag or branch from github.com/pcengines/coreboot"
    echo "  <platform> - apu2, apu3, apu4 or apu5"
    echo "  <menuconfig-param> - menuconfig interface, give 'help' for more information"
    exit
fi

if [ ! -d coreboot ]; then
    git clone https://github.com/pcengines/coreboot.git -b coreboot-sdk-support
fi

cd coreboot && git checkout $1
git submodule update --init --checkout
cd ..

# docker pull pcengines/pce-fw-builder:latest
docker run --rm -it -v $PWD/coreboot:/home/coreboot/coreboot pcengines/pce-fw-builder:latest \
    /home/coreboot/scripts/pce-fw-builder.sh $*
