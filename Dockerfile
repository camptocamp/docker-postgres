ARG BASE_TAG
FROM postgres:${BASE_TAG}-trixie AS builder

ENV PGVECTOR_VERSION=0.8.1
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
FROM postgres:${BASE_TAG}-trixie

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

RUN cp /usr/share/i18n/SUPPORTED /etc/locale.gen && \
    locale-gen

ADD 99force-gpgv /tmp/99force-gpgv

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y gpgv libbrotli-dev curl lsb-release ca-certificates gnupg && \
    mv /tmp/99force-gpgv /etc/apt/apt.conf.d/99force-gpgv && \
    echo "deb http://apt.dalibo.org/labs $(lsb_release -cs)-dalibo main" > /etc/apt/sources.list.d/dalibo-labs.list && \
    curl -fsSL -o /etc/apt/trusted.gpg.d/dalibo-labs.gpg https://apt.dalibo.org/labs/debian-dalibo.gpg && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    postgresql-$PG_MAJOR-postgis-3 \
    postgresql-$PG_MAJOR-postgis-3-scripts \
    postgresql_anonymizer_$PG_MAJOR; \
    apt-get install --no-install-recommends -y postgresql-$PG_MAJOR-pgrouting && \
    apt-get install -y tmux screen less && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG BARMAN_VERSION="3.17.0"

# We need to break the system packages to install barman-cloud in bookworm and later
ENV PIP_BREAK_SYSTEM_PACKAGES=1

USER root
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		# We require build-essential and python3-dev to build lz4 on arm64 since there isn't a pre-compiled wheel available
		build-essential python3-dev \
		python3-pip \
		python3-psycopg2 \
		python3-setuptools \
	&& \
	pip3 install --no-cache-dir barman[cloud,azure,snappy,google,zstandard,lz4]==${BARMAN_VERSION} && \
	python3 -c "import sysconfig, compileall; compileall.compile_dir(sysconfig.get_path('stdlib'), quiet=1); compileall.compile_dir(sysconfig.get_path('purelib'), quiet=1); compileall.compile_dir(sysconfig.get_path('platlib'), quiet=1)" && \
	apt-get remove -y --purge --autoremove build-essential python3-dev && \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
	rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/*

COPY --from=builder /pgvector_install /
COPY --from=builder /wal-g-v1.1 /usr/local/bin/wal-g-v1.1
COPY --from=builder /wal-g-v2.0.1 /usr/local/bin/wal-g-v2.0.1

RUN cd /usr/local/bin/ && \
    ln -s wal-g-v2.0.1 wal-g
