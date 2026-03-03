PGHOST := $(shell ip -json addr|jq -r '.[] | select(.ifname | test("^docker0$$")) | .addr_info[] | select(.family | test("^inet$$")) | .local')

define build-image
	@echo Base tag $1
	docker build --pull --no-cache --build-arg BASE_TAG=${1} -t ghcr.io/camptocamp/postgres:${1} .
	docker stop db || true
	docker run --rm --name=db --detach --publish=5432:5432 --env=POSTGRES_USER=www-data --env=POSTGRES_PASSWORD=www-data --env=POSTGRES_DB=test ghcr.io/camptocamp/postgres:${1}
	sleep 10
	docker logs db
	docker run --rm --env=PGUSER=www-data --env=PGPASSWORD=www-data --env=PGDATABASE=test --env=PGPORT=5432 --env=PGHOST=$(PGHOST) ghcr.io/camptocamp/postgres:${1} psql --command="SELECT 1"
	docker stop db
	$(if ${PUSH_GHCR},docker push ghcr.io/camptocamp/postgres:${1},)
	docker system prune --all -f
endef

all: 14 15 16 17 18

14:
	$(call build-image,"14")

15:
	$(call build-image,"15")

16:
	$(call build-image,"16")

17:
	$(call build-image,"17")

18:
	$(call build-image,"18")
