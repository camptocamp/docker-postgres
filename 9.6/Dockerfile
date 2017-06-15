FROM postgres:9.6

RUN apt-get update \
  && for POSTGIS_VERSION in 2.3; do \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    postgresql-contrib-$PG_MAJOR=$PG_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
    postgresql-$PG_MAJOR-pgrouting; \
    done \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
