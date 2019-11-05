ARG BASE_TAG

FROM postgres:${BASE_TAG}

ARG POSTGISVERSIONS

RUN apt-get update && \
    for POSTGIS_VERSION in $POSTGIS_VERSIONS; do \
      DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      postgresql-contrib \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
      postgresql-$PG_MAJOR-pgrouting; \
    done \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
