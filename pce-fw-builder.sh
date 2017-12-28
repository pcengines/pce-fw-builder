#!/bin/bash

echo $*

cd /home/coreboot/coreboot
make distclean
cp configs/pcengines_$2.config .config
make -j$(nproc)

