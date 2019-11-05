define build-image-9.x
	@echo Base tag $1
	@echo Postgis versions $2
	docker build --no-cache --build-arg BASE_TAG=$1 --build-arg POSTGISVERSIONS=$2 -t camptocamp/postgres:$1 9.x
endef

.PHONY: 9.4 9.5

9.4:
	$(call build-image-9.x,"9.4","2.3 2.4 2.5")

9.5:
	$(call build-image-9.x,"9.5","2.3 2.4 2.5")
