ARG BASE_TAG
ARG DEBIAN_RELEASE
FROM postgres:${BASE_TAG}-${DEBIAN_RELEASE} AS builder
ARG PGVECTOR_VERSION
RUN apt-get update && \
    apt-get install -y unzip build-essential git wget libbrotli-dev postgresql-server-dev-$PG_MAJOR

# Install Golang
RUN wget https://go.dev/dl/go1.25.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.6.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin
RUN go version

# Install Wal-g 1.1
WORKDIR /usr/src
RUN git clone --progress --branch v1.1 https://github.com/wal-g/wal-g.git

WORKDIR wal-g

RUN git submodule update --init --recursive --force --progress && \
    go mod vendor && \
    make pg_build

RUN ./main/pg/wal-g --version && \
    cp ./main/pg/wal-g /wal-g-v1.1

RUN git checkout v2.0.1 && \
    git submodule update --init --recursive --force --progress && \
    go mod vendor && \
    make pg_build

RUN ./main/pg/wal-g --version && \
    cp ./main/pg/wal-g /wal-g-v2.0.1

# Build pgvector extension
WORKDIR /tmp
RUN wget https://github.com/pgvector/pgvector/archive/refs/tags/v${PGVECTOR_VERSION}.tar.gz && \
    tar -xzf v${PGVECTOR_VERSION}.tar.gz && \
    rm v${PGVECTOR_VERSION}.tar.gz && \
    mv pgvector-${PGVECTOR_VERSION} pgvector

WORKDIR /tmp/pgvector
RUN make && make DESTDIR=/pgvector_install install

ARG BASE_TAG
ARG DEBIAN_RELEASE
FROM postgres:${BASE_TAG}-${DEBIAN_RELEASE}

ARG POSTGIS_VERSIONS
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

RUN cp /usr/share/i18n/SUPPORTED /etc/locale.gen && \
    locale-gen

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y libbrotli-dev && \
    echo "Postgis versions '$POSTGIS_VERSIONS'" && \
    for POSTGIS_VERSION in ${POSTGIS_VERSIONS}; do \
      apt-get install --no-install-recommends -y \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts; \
    done && \
    apt-get install --no-install-recommends -y postgresql-$PG_MAJOR-pgrouting && \
    apt-get install -y ca-certificates tmux screen curl less && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /pgvector_install /
COPY --from=builder /wal-g-v1.1 /usr/local/bin/wal-g-v1.1
COPY --from=builder /wal-g-v2.0.1 /usr/local/bin/wal-g-v2.0.1

RUN cd /usr/local/bin/ && \
    ln -s wal-g-v2.0.1 wal-g
