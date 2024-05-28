MNT = /mnt/rootfs-debian

default:
	sudo ./make_base.sh $(FS_SRC)

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






