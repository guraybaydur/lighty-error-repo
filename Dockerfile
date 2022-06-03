FROM debian:buster-20210408-slim

RUN apt-get update && apt-get install -y \
    libssl-dev \
    wget unzip openssh-client

ADD confd-basic-7.5.1.linux.x86_64.zip ./
RUN unzip confd-basic-7.5.1.linux.x86_64.zip; ./confd-basic-7.5.1.linux.x86_64/confd-basic-7.5.1.linux.x86_64.installer.bin /confd; \
        rm -rf /confd/doc /confd/examples.confd /confd/man /confd/src ./confd-basic-7.5.1.linux.x86_64.zip ./confd-basic-7.5.1.linux.x86_64; \
        apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
        bash -c "source /confd/confdrc" 

ADD confd.conf.xml /confd/etc/confd
ADD confd.conf.xml /confd/etc/confd/confd.conf

RUN ls /confd/etc/confd/
RUN cat /confd/etc/confd/confd.conf

ADD custom-yangs/ ./custom-yangs
WORKDIR /custom-yangs


ENV CONFD_DIR=/confd
ENV LD_LIBRARY_PATH=/confd/lib
ENV PATH=/confd/bin:$PATH
ENV CDB_DIR=${CONFD_DIR}/var/confd/cdb

EXPOSE 2022
EXPOSE 2023
EXPOSE 2024
EXPOSE 4565
EXPOSE 8008
EXPOSE 8088

# Start init daemon and ConfD
ENTRYPOINT ["confd"]
CMD ["--addloadpath", "/confd/etc/confd", "--addloadpath", "/custom-yangs/", "--foreground", "--verbose"]
