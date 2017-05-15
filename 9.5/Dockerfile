FROM postgres:9.5

ENV POSTGIS_VERSION=2.3

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION=$PG_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts=$PG_VERSION \
    postgresql-contrib-$PG_MAJOR=$PG_VERSION \
    postgresql-$PG_MAJOR-pgrouting=$PG_VERSION \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
