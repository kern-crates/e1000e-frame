# E1000 驱动 Rust 版开发框架

# 安装依赖

```shell
sudo apt install qemu-system  qemu-user-static  debootstrap -y
```

# 构建与运行

```shell
# 构建docker image
make docker_build

# linux 默认配置
make defconfig

# linux 配置，需打开 Rust，并把e1000、e1000e 设为 <M>
make menuconfig

# build linux and e1000
make all

# 编译busybox
make busybox

# 创建文件系统
make busybox_image

# 运行qemu
make quick_test
```

# 网络测试

```shell
# qemu 中
# 卸载e1000e
rmmod e1000e
# 挂载rust e1000
modprobe e1000-rs
ip link set dev enp0s2 down
ip link set dev enp0s2 up
dhclient 
ping www.baidu.com
```

```shell
# busybox
modprobe e1000-rs
ip addr add 10.0.2.15/24 dev eth0
ip link set eth0 up
ip route add default via 10.0.2.2
ping 10.0.2.2
```

# 物理机测试

```shell
# 打包
make pack

#目标机器
rm -rf out
tar -xvf out.tar.gz
cp -rf out/boot/* /boot
cp -rf out/modules/lib/modules/* /lib/modules
dracut /boot/initramfs-6.1.0.img 6.1.0
grub2-mkconfig -o /boot/efi/EFI/openEuler/grub.cfg

reboot

echo "8    4    1    7" > /proc/sys/kernel/printk
```