FROM coreboot/coreboot-sdk:2021-04-06_7014f8258e
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>
USER root
COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
