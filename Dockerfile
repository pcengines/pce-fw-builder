FROM coreboot/coreboot-sdk:1.50
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>

RUN mkdir -p /home/coreboot/scripts
ADD pce-fw-builder.sh /home/coreboot/scripts/pce-fw-builder.sh

