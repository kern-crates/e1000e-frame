THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MAKEFILE_DIR := $(dir $(THIS_MAKEFILE))
KDIR=$(THIS_MAKEFILE_DIR)linux
MDIR=$(THIS_MAKEFILE_DIR)driver-e1000
DOCKER_IMAGE=Ubuntu20/e1000
RUST_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh rustc)
BINDGEN_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh bindgen)
RUN=docker run --rm -it -v $(THIS_MAKEFILE_DIR):$(THIS_MAKEFILE_DIR) $(DOCKER_IMAGE)


default:
	echo $(KDIR)

docker_build:
	docker build --build-arg rust_version=$(RUST_VERSION) --build-arg  bindgen_version=$(BINDGEN_VERSION) -t $(DOCKER_IMAGE) $(THIS_MAKEFILE_DIR)docker

menuconfig:
	$(MAKE) -C $(KDIR) LLVM=1 menuconfig	

test:
	$(RUN) make -C $(KDIR)  LLVM=1 rustavailable