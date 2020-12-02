FROM coreboot/coreboot-sdk:1.52
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>
USER root
COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
