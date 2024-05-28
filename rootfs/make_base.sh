#!/bin/sh
FS_SRC="$1"
echo "make rootfs base: $FS_SRC"
if [ -d "$FS_SRC" ]; then
    echo "rootfs base exist"
    exit 0
fi

INSTALL="--include=locales,vim,bash-completion,udev,net-tools,iputils-ping,ethtool,rsyslog,bash-completion,kmod,pciutils,iperf3,ifupdown"
cmd="sudo debootstrap --arch=amd64 $INSTALL buster $FS_SRC https://mirrors.ustc.edu.cn/debian/"
echo $cmd
$cmd
 
# 删除 root 密码
sed -i '/^root/ { s/:x:/::/ }' $FS_SRC/etc/passwd 
echo "127.0.0.1 localhost" > ${FS_SRC}/etc/hosts
echo "nameserver 223.5.5.5 " >> ${FS_SRC}/etc/resolv.conf
cat > ${FS_SRC}/etc/network/interfaces.d/enp0s2.cfg << EOF
allow-hotplug enp0s2
iface enp0s2 inet dhcp
EOF

echo "rootfs base ok"