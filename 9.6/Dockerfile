FROM postgres:9.6
MAINTAINER Camptocamp "info@camptocamp.com"

RUN apt-get update \
  && apt-get install --no-install-recommends -y postgresql-9.6-postgis-2.3 postgresql-9.6-postgis-2.3-scripts postgresql-contrib-9.6 postgresql-9.6-pgrouting \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
