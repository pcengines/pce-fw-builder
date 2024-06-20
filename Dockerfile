FROM coreboot/coreboot-sdk:2024-03-30_cccada28f7
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>
USER root
COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
