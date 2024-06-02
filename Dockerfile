FROM coreboot/coreboot-sdk:2024-05-20_b4949d3de5
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>
USER root
COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
