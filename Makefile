THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
DIR := $(dir $(THIS_MAKEFILE))
KDIR=$(DIR)linux
MDIR=$(DIR)driver-e1000
DOCKER_IMAGE=Ubuntu22/e1000
RUST_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh rustc)
BINDGEN_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh bindgen)
RUN=docker run --rm -it -v $(DIR):$(DIR) $(DOCKER_IMAGE)
export FS_BASE=debian12
export FS_DIR=$(DIR)rootfs/$(FS_BASE)

KMAKE=$(RUN) make -C $(KDIR) O=$(KDIR) LLVM=1 

default:
	$(KMAKE) -j$(shell nproc)

docker_build:
	docker build --build-arg rust_version=$(RUST_VERSION) --build-arg  bindgen_version=$(BINDGEN_VERSION) -t $(DOCKER_IMAGE) $(DIR)docker

menuconfig:
	$(KMAKE) menuconfig		

defconfig:
	$(KMAKE) defconfig

test:
	$(KMAKE) rustavailable

.PHONY: rootfs
rootfs:
	$(MAKE) -C $(DIR)rootfs -f Makefile $(MAKEFLAGS)


	