
default:
	echo "make rootfs: $(FS_BASE)"
	if [ ! -d $(FS_DIR) ];then \
	sudo debootstrap --arch=amd64 \
	--include=systemd,systemd-coredump,makedev,locales,vim,bash-completion,\
	udev,net-tools,iputils-ping,ethtool,ifupdown,rsyslog,bash-completion,iperf3,kmod,pciutils \
	buster $(FS_BASE) http://mirrors.163.com/debian/ ; \
	fi
	echo "rootfs base ok"

clean:
	sudo rm -rf $(FS_DIR)






