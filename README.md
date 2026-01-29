# Camptocamp's PostgreSQL Docker container

[![Build PostgreSQL images](https://github.com/camptocamp/docker-postgres/actions/workflows/ci.yaml/badge.svg)](https://github.com/camptocamp/docker-postgres/actions/workflows/ci.yaml)

This image extends the [official PostgreSQL image](https://hub.docker.com/_/postgres/) with the following features:

- [PostGIS](http://postgis.net/)
- [pgRouting](http://pgrouting.org/)
- [PostgreSQL contrib package](https://packages.debian.org/sid/postgresql-contrib-9.6)
- [Wal-g backup tools](https://github.com/wal-g/wal-g)
- [pgvector 0.8.1](https://github.com/pgvector/pgvector)

See the PostgreSQL image documentation for more details:
https://hub.docker.com/_/postgres/
