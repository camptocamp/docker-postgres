space := $(subst ,, )

define build-image
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --pull --no-cache --build-arg BASE_TAG=${1} --build-arg POSTGIS_VERSIONS=${2} -t camptocamp/postgres:${1}-postgis-$(subst $(space),-,${2}) 1x
endef

all: 9.4 9.5 9.6 10 11 12 13

.PHONY: 9.4 9.5 9.6 10 11 12 13

9.4:
	$(call build-image,"9.4","2.3 2.4 2.5")

9.5:
	$(call build-image,"9.5","2.2 2.3")

9.6:
	$(call build-image,"9.5","2.3")

10:
	$(call build-image,"10","2.4")

11:
	$(call build-image,"11","2.5")
	$(call build-image,"11","3")

12:
	$(call build-image,"12","2.5")
	$(call build-image,"12","3")

13:
	$(call build-image,"13","2.5")
	$(call build-image,"13","3")
