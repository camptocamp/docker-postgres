ARG BASE_TAG
FROM postgres:${BASE_TAG} AS builder

RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free"  > /etc/apt/sources.list.d/backport.list && \
    apt-get update && \
    apt-get install -y unzip build-essential git wget libbrotli-dev

# Install Golang
RUN wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz

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

ARG BASE_TAG
FROM postgres:${BASE_TAG}

ARG POSTGIS_VERSIONS
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free"  > /etc/apt/sources.list.d/backport.list && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y libbrotli-dev && \
    echo "Postgis versions '$POSTGIS_VERSIONS'" && \
    for POSTGIS_VERSION in ${POSTGIS_VERSIONS}; do \
      apt-get install --no-install-recommends -y \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
      postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts; \
    done && \
    apt-get install --no-install-recommends -y postgresql-$PG_MAJOR-pgrouting && \
    if [ $(echo $PG_MAJOR | cut -f 1 -d .) -ge "10" ]; then \
      apt-get install --no-install-recommends -y postgresql-contrib; \
    else \
      apt-get install --no-install-recommends -y postgresql-contrib-$PG_MAJOR; \
    fi && \
    apt-get install -y ca-certificates tmux screen curl less && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /wal-g-v1.1 /usr/local/bin/wal-g-v1.1
COPY --from=builder /wal-g-v2.0.1 /usr/local/bin/wal-g-v2.0.1

RUN cd /usr/local/bin/ && \
    ln -s wal-g-v2.0.1 wal-g
