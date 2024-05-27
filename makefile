THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MAKEFILE_DIR := $(dir $(THIS_MAKEFILE))
KDIR=$(THIS_MAKEFILE_DIR)linux
MDIR=$(THIS_MAKEFILE_DIR)driver-e1000
DOCKER_IMAGE=Ubuntu22/e1000
RUST_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh rustc)
BINDGEN_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh bindgen)
RUN=docker run --rm -it -v $(THIS_MAKEFILE_DIR):$(THIS_MAKEFILE_DIR) $(DOCKER_IMAGE)
KMAKE = $(RUN) make -C $(KDIR) O=$(KDIR) LLVM=1 

default:
	$(KMAKE) -j$(shell nproc)

docker_build:
	docker build --build-arg rust_version=$(RUST_VERSION) --build-arg  bindgen_version=$(BINDGEN_VERSION) -t $(DOCKER_IMAGE) $(THIS_MAKEFILE_DIR)docker

menuconfig:
	$(KMAKE) menuconfig		

defconfig:
	$(KMAKE) defconfig

test:
	$(KMAKE) rustavailable