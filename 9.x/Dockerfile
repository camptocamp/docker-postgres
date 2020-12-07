ARG BASE_TAG
FROM postgres:${BASE_TAG}

ARG POSTGISVERSIONS
ENV DEBIAN_FRONTEND=noninteractive
ENV WALG_VERISON=0.2.19
ENV WALG_SHA=e4be62bbdb19e088a1419dff7a30350ceb6762cfba2c57120c92bb7b92303e98

RUN apt-get update && apt-get upgrade -y && \
    echo "Postgis versions '$POSTGIS_VERSIONS'" && \
    for POSTGIS_VERSION in $POSTGISVERSIONS ; do \
      apt-get install --no-install-recommends -y \
      postgresql-contrib-$PG_MAJOR=$PG_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
      postgresql-$PG_MAJOR-pgrouting; \
    done \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/src/github.com/wal-g/wal-g/main/pg/wal-g /bin/
