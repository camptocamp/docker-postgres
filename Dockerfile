ARG BASE_TAG
FROM postgres:${BASE_TAG}

ARG POSTGIS_VERSIONS
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN echo "Postgis versions '$POSTGIS_VERSIONS'" && \
    for POSTGIS_VERSION in ${POSTGIS_VERSIONS}; do \
      apt-get install --no-install-recommends -y \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts; \
    done && \
    apt-get install --no-install-recommends -y postgresql-$PG_MAJOR-pgrouting && \
    if [ $(echo $PG_MAJOR | cut -f 1 -d .) -ge "10" ]; then \
      apt-get install --no-install-recommends -y postgresql-contrib; \
    else \
      apt-get install --no-install-recommends -y postgresql-contrib-$PG_MAJOR; \
    fi && \
    apt-get install -y ca-certificates tmux screen curl less && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV WALG_VERISON=1.0
ENV WALG_SHA=35e95fe25ea82d24d190b417f33d7069c89413d3c662c3a358c3bcd794c809a2

RUN curl -L -s https://github.com/wal-g/wal-g/releases/download/v${WALG_VERISON}/wal-g-pg-ubuntu-18.04-amd64 \
    -o /usr/local/bin/wal-g && \
    chmod +x /usr/local/bin/wal-g && \
    [ $(sha256sum /usr/local/bin/wal-g | cut -f1 -d' ') = ${WALG_SHA} ]
