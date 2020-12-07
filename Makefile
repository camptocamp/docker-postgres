define build-image
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --pull --build-arg BASE_TAG=$1 --build-arg POSTGIS_VERSIONS=$2 -t camptocamp/postgres:$1-postgis-$2 1x
endef

define build-image-9.x
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --pull --build-arg BASE_TAG=$1 --build-arg POSTGIS_VERSIONS=$2 -t camptocamp/postgres:$1 9.x
endef

define build-image-1x
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --pull --build-arg BASE_TAG=$1 --build-arg POSTGIS_VERSIONS=$2 -t camptocamp/postgres:$1 1x
endef

all: 9.4 9.5 9.6 10 11 12

.PHONY: 9.4 9.5 9.6 10 11 12

9.4:
	$(call build-image-1x,"9.4","2.3 2.4 2.5")

9.5:
	$(call build-image-1x,"9.5","2.2 2.3")

9.6:
	$(call build-image-1x,"9.5","2.3")

10:
	$(call build-image-1x,"10","2.4")

11:
	$(call build-image-1x,"11","3.0")

12:
	$(call build-image-1x,"12","3")
