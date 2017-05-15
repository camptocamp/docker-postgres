FROM postgres:9.5

RUN apt-get update \
  && apt-get install --no-install-recommends -y postgresql-9.5-postgis-2.3 postgresql-9.5-postgis-2.3-scripts postgresql-contrib-9.5 postgresql-9.5-pgrouting \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
