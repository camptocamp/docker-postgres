define build-image-9.x
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --build-arg BASE_TAG=$1 --build-arg POSTGISVERSIONS=$2 -t camptocamp/postgres:$1 9.x
endef

define build-image-1x
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --build-arg BASE_TAG=$1 --build-arg POSTGISVERSIONS=$2 -t camptocamp/postgres:$1 1x
endef

all: 9.4 9.5 9.6 10 11

.PHONY: 9.4 9.5 9.6 10 11

9.4:
	$(call build-image-9.x,"9.4","2.3 2.4 2.5")

9.5:
	$(call build-image-9.x,"9.5","2.2 2.3")

9.6:
	$(call build-image-9.x,"9.5","2.3")

10:
	$(call build-image-1x,"10","2.4")

11:
	$(call build-image-1x,"11","2.5")
