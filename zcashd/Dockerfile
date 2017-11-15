FROM debian:jessie
MAINTAINER recursethis

# install latest zcash
RUN apt-get update \
    && apt-get install -y apt-transport-https wget \
    && wget -qO - https://apt.z.cash/zcash.asc | apt-key add - \
    && echo "deb [arch=amd64] https://apt.z.cash/ jessie main" | tee /etc/apt/sources.list.d/zcash.list \
    && apt-get update && apt-get install -y zcash \
    && apt-get autoclean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && zcash-fetch-params

ENV ZCASH_CONF_DIR /config
ENV ZCASH_CONF ${ZCASH_CONF_DIR}/zcash.conf
WORKDIR /root/.zcash

# generate configuration
RUN mkdir -p ${ZCASH_CONF_DIR} \
    && echo "rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1`" >> ${ZCASH_CONF} \
    && echo "rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`" >> ${ZCASH_CONF} \
    && echo "testnet=1" >> ${ZCASH_CONF} \
    && echo "addnode=testnet.z.cash" >> ${ZCASH_CONF} \
    && echo "rpcallowip=172.23.0.0/16" >> ${ZCASH_CONF} \
    && echo "rpcport=18232" >> ${ZCASH_CONF} \
    && cat ${ZCASH_CONF} \
    && ln -s ${ZCASH_CONF} /root/.zcash/zcash.conf \
    && echo `zcash-cli --version`

ENTRYPOINT ["zcashd"]
