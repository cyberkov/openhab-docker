TARGET ?= amd64
ARCHS ?= amd64 armhf arm64
BASE_ARCH ?= amd64
DOCKER_REPO ?= openhab/openhab
FLAVOR ?= online

ifeq ($(FLAVOR),offline)
  DOWNLOAD_URL="https://openhab.ci.cloudbees.com/job/openHAB-Distribution/lastSuccessfulBuild/artifact/distributions/openhab-offline/target/openhab-offline-2.0.0-SNAPSHOT.zip"
else
  DOWNLOAD_URL="https://openhab.ci.cloudbees.com/job/openHAB-Distribution/lastSuccessfulBuild/artifact/distributions/openhab-online/target/openhab-online-2.0.0-SNAPSHOT.zip"
endif

build: tmp-$(TARGET)/Dockerfile
	docker build --build-arg ARCH=$(TARGET) --build-arg DOWNLOAD_URL=$(DOWNLOAD_URL) -t $(DOCKER_REPO):$(TARGET)-$(FLAVOR) tmp-$(TARGET)
	docker run --rm $(DOCKER_REPO):$(TARGET)-$(FLAVOR) uname -a
	docker run --rm $(DOCKER_REPO):$(TARGET)-$(FLAVOR) ls -la /openhab

# $(shell find files-common files-$(TARGET))
tmp-$(TARGET)/Dockerfile: Dockerfile $(shell find files)
	rm -rf tmp-$(TARGET)
	mkdir tmp-$(TARGET)
	cp Dockerfile $@
	cp -rf files tmp-$(TARGET)/
#	cp -rf files-$(TARGET) tmp-$(TARGET)/
	for arch in $(ARCHS); do                     \
	  if [ "$$arch" != "$(TARGET)" ]; then       \
	    sed -i "/arch=$$arch/d" $@;              \
	  fi;                                        \
	done
	sed -i '/#[[:space:]]*arch=$(TARGET)/s/^#//' $@
	sed -i 's/#[[:space:]]*arch=$(TARGET)//g' $@
	cat $@

clean:
	for arch in $(ARCHS); do                     \
	  rm -rf tmp-$$arch;                      \
	done

push:
	docker push $(DOCKER_REPO):$(TARGET)-$(FLAVOR)
