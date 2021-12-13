space := $(subst ,, )

define build-image
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --pull --no-cache --build-arg BASE_TAG=${1} --build-arg POSTGIS_VERSIONS=${2} -t camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}) .
	$(if ${PUSH_DOCKER_HUB},docker push camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}),)
	$(if ${PUSH_GHCR},docker tag camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}) ghcr.io/camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}),)
	$(if ${PUSH_GHCR},docker push ghcr.io/camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}),)
endef

all: 9.6 10 11 12 13


9.6:
	$(call build-image,"9.6","3")

10:
	$(call build-image,"10","4")

11:
	$(call build-image,"11","3")

12:
	$(call build-image,"12","3")

13:
	$(call build-image,"13","3")
