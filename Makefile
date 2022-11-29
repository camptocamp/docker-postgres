space := $(subst ,, )
PGHOST := $(shell ip -json addr|jq -r '.[] | select(.ifname | test("^docker0$$")) | .addr_info[] | select(.family | test("^inet$$")) | .local')


define build-image
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --pull --no-cache --build-arg BASE_TAG=${1} --build-arg POSTGIS_VERSIONS=${2} -t camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}) .
	docker stop db || true
	docker run --rm --name=db --detach --publish=5432:5432 --env=POSTGRES_USER=www-data --env=POSTGRES_PASSWORD=www-data --env=POSTGRES_DB=test camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2})
	sleep 10
	docker logs db
	docker run --rm --env=PGUSER=www-data --env=PGPASSWORD=www-data --env=PGDATABASE=test --env=PGPORT=5432 --env=PGHOST=$(PGHOST) \
		camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}) psql --command="SELECT 1"
	docker stop db
	$(if ${PUSH_DOCKER_HUB},docker push camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}),)
	$(if ${PUSH_GHCR},docker tag camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}) ghcr.io/camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}),)
	$(if ${PUSH_GHCR},docker push ghcr.io/camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}),)
	docker system prune --all -f
endef

all: 10 11 12 13 14

10:
	$(call build-image,"10","2.4")

11:
	$(call build-image,"11","2.5")
	$(call build-image,"11","3")

12:
	$(call build-image,"12","3")

13:
	$(call build-image,"13","3")

14:
	$(call build-image,"14","3")
