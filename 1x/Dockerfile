ARG BASE_TAG
FROM golang:1.13 as builder
RUN go get github.com/wal-g/wal-g || true && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y cmake liblzo2-dev
WORKDIR /go/src/github.com/wal-g/wal-g
RUN make install deps pg_build

FROM postgres:${BASE_TAG}

ARG POSTGIS_VERSIONS

RUN apt-get update && \
    echo "Postgis versions '$POSTGIS_VERSIONS'" && \
    for POSTGIS_VERSION in ${POSTGIS_VERSIONS}; do \
      DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      postgresql-contrib \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
      postgresql-$PG_MAJOR-pgrouting; \
    done \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/src/github.com/wal-g/wal-g/main/pg/wal-g /bin/
