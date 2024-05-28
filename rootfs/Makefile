MNT = /mnt/rootfs-debian

default:
	echo "make rootfs: $(FS_BASE)"
	if [ ! -d $(FS_SRC) ];then \
	sudo debootstrap --arch=amd64 \
	--include=locales,vim,bash-completion,\
	udev,net-tools,iputils-ping,ethtool,rsyslog,bash-completion,kmod,pciutils,iperf3,ifupdown \
	buster   $(FS_BASE)  https://mirrors.ustc.edu.cn/debian/ ; \
	sudo sed -i '/^root/ { s/:x:/::/ }' $(FS_BASE)/etc/passwd ; \
	fi

	echo "rootfs base ok"

image:
	if [ -e "$(FS_IMAGE_NAME)" ]; then \
		echo "File $(FS_IMAGE_NAME) exists. Deleting now."; \
		rm $(FS_IMAGE_NAME); \
	fi
	sudo mkdir -p $(MNT)
	dd if=/dev/zero of=$(FS_IMAGE_NAME) bs=1M count=1524
	mkfs.ext4 $(FS_IMAGE_NAME)
	sudo mount -t ext4 $(FS_IMAGE_NAME) $(MNT)
	sudo cp -raf $(FS_BASE)/* $(MNT)
	sudo umount $(MNT)
	sudo chmod 777 $(FS_IMAGE_NAME)

clean:
	sudo rm -rf $(FS_SRC)






