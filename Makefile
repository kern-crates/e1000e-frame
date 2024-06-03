THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
DIR := $(dir $(THIS_MAKEFILE))

VENV=$(DIR).pyenv
PYTHON := $(VENV)/bin/python

USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)

KDIR=$(DIR)linux
MDIR=$(DIR)driver-e1000
DOCKER_IMAGE=Ubuntu22/e1000v2
RUST_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh rustc)
BINDGEN_VERSION=$(shell $(KDIR)/scripts/min-tool-version.sh bindgen)
BINDGEN_CMD=$(shell $(PYTHON) $(DIR)check_bindgen.py $(BINDGEN_VERSION))
DOCKER_RUN_BASE=docker run --rm -it  --user "$(USER_ID):$(GROUP_ID)" -v $(DIR):$(DIR) 
RUN=$(DOCKER_RUN_BASE) $(DOCKER_IMAGE)
SUB_FS=$(DIR)rootfs
export FS_BASE=fs_base
export FS_SRC=$(SUB_FS)/$(FS_BASE)
export FS_IMAGE_NAME=initrd.img
MOD_PATH=$(FS_SRC)
DRIVER_SRC=$(DIR)driver-e1000/src 
KMAKE=$(RUN) make -C $(KDIR) O=$(KDIR) LLVM=1 
OUT_DIR=$(DIR)out


default:
	$(KMAKE) -j$(shell nproc)

	$(KMAKE) rust-analyzer

docker_build: 
	docker build \
	--build-arg rust_version=$(RUST_VERSION) \
	--build-arg  bindgen_version=$(BINDGEN_VERSION) \
	--build-arg  bindgen_cmd=$(BINDGEN_CMD) \
	--build-arg  USER_NAME=$(USER) \
	--build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID) \
	-t $(DOCKER_IMAGE) $(DIR)docker
	rustup override set $(RUST_VERSION)
	rustup component add rust-src

menuconfig:
	$(KMAKE) menuconfig		

defconfig:
	$(KMAKE) defconfig

test:
	$(RUN) whereis rustup


e1000:
	$(RUN) bash -c "cd $(MDIR) && make -C $(KDIR) M=$(MDIR)  LLVM=1 rust-analyzer"
	$(RUN) bash -c "cd $(MDIR) && bear -- make -C $(KDIR) M=$(MDIR)  LLVM=1 -j$(shell nproc)"

kernel:
	$(RUN) bash -c "cd $(KDIR) && bear -- make  LLVM=1 -j$(shell nproc)"
	$(RUN) bash -c "cd $(KDIR) && make  LLVM=1 rust-analyzer"

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
		-nic user,model=e1000e,id=net1,net=192.168.1.0/24,dhcpstart=192.168.1.10

clangd:
	$(RUN) $(KDIR)/scripts/clang-tools/gen_compile_commands.py -d $(KDIR) -o $(DIR)compile_commands.json


pack: 
	rm -rf $(OUT_DIR)
	mkdir -p $(OUT_DIR)/boot
	mkdir -p $(OUT_DIR)/modules
	$(KMAKE) INSTALL_PATH=$(OUT_DIR)/boot install
	$(KMAKE)  modules_install	INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(OUT_DIR)/modules
	# $(KMAKE) M=$(MDIR) modules_install	INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(OUT_DIR)/modules
	tar -czf out.tar.gz -C $(DIR) out