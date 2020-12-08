ARG BASE_TAG
FROM postgres:${BASE_TAG}

ARG POSTGIS_VERSIONS
ENV DEBIAN_FRONTEND=noninteractive
ENV WALG_VERISON=0.2.19
ENV WALG_SHA=e4be62bbdb19e088a1419dff7a30350ceb6762cfba2c57120c92bb7b92303e98

RUN apt-get update && apt-get upgrade -y && \
    echo "Postgis versions '$POSTGIS_VERSIONS'" && \
    for POSTGIS_VERSION in ${POSTGIS_VERSIONS}; do \
      apt-get install --no-install-recommends -y \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
      postgresql-$PG_MAJOR-pgrouting; \
    done && \
    if [ "$PG_MAJOR" -ge "10" ]; then \
      apt-get install --no-install-recommends -y postgresql-contrib; \
    else \
      apt-get install --no-install-recommends -y postgresql-contrib-$PG_MAJOR=$PG_VERSION; \
    fi && \
    apt-get install -y ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://github.com/wal-g/wal-g/releases/download/v${WALG_VERISON}/wal-g.linux-amd64.tar.gz | \
    tar xvz -C /usr/local/bin && \
    [ $(sha256sum /usr/local/bin/wal-g | cut -f1 -d' ') = ${WALG_SHA}]
