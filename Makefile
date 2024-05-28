THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
DIR := $(dir $(THIS_MAKEFILE))
KDIR=$(DIR)linux
MDIR=$(DIR)driver-e1000/src
DOCKER_IMAGE=Ubuntu22/e1000
RUST_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh rustc)
BINDGEN_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh bindgen)
RUN=docker run --rm -it -v $(DIR):$(DIR) $(DOCKER_IMAGE)
SUB_FS=$(DIR)rootfs
export FS_BASE=fs_base
export FS_SRC=$(SUB_FS)/$(FS_BASE)
export FS_IMAGE_NAME=initrd.img
MOD_PATH=$(FS_SRC)
DRIVER_SRC=$(DIR)driver-e1000/src 

KMAKE=$(RUN) make -C $(KDIR) O=$(KDIR) LLVM=1 

default:
	$(KMAKE) -j$(shell nproc)
	$(KMAKE) modules -j$(shell nproc)
	$(KMAKE) bzImage

docker_build:
	docker build --build-arg rust_version=$(RUST_VERSION) --build-arg  bindgen_version=$(BINDGEN_VERSION) -t $(DOCKER_IMAGE) $(DIR)docker

menuconfig:
	$(KMAKE) menuconfig		

defconfig:
	$(KMAKE) defconfig

test:
	$(KMAKE) rustavailable
	$(RUN) whereis depmod

e1000:
	$(KMAKE) M=$(MDIR)

kernel:
	$(KMAKE) -j$(shell nproc)
	$(KMAKE) modules -j$(shell nproc)
	$(KMAKE) bzImage

all:
	$(MAKE) kernel
	$(MAKE) e1000


install:
	$(KMAKE)  modules_install	INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(FS_SRC)
	$(KMAKE) M=$(MDIR) modules_install	INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(FS_SRC)

.PHONY: rootfs
rootfs:
	$(MAKE) -C $(SUB_FS)
	$(MAKE) install
	$(MAKE) -C $(SUB_FS) image

rootfs_clean:
	$(MAKE) -C $(SUB_FS) clean

qemu: 
	sudo qemu-system-x86_64 -smp 2 -m 2G \
  		-kernel "$(KDIR)/arch/x86_64/boot/bzImage" \
  		-hda $(SUB_FS)/initrd.img \
  		-nographic -vga none \
		-append "root=/dev/sda console=ttyS0" -nographic \
		-no-reboot \
		-nic user,model=e1000e,id=net1,net=192.168.1.0/24,dhcpstart=192.168.1.1

	
