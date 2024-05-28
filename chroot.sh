#!/bin/bash

# 设置你的根文件系统路径
ROOTFS_PATH="rootfs/fs_base"

# 检查是否提供了 ROOTFS_PATH 的有效路径
if [ ! -d "$ROOTFS_PATH" ]; then
    echo "Error: Root filesystem directory does not exist."
    exit 1
fi

# 挂载必要的系统目录
    sudo mount -t proc /proc ${ROOTFS_PATH}/proc
    sudo mount -t sysfs /sys ${ROOTFS_PATH}/sys
    sudo mount -o bind /dev ${ROOTFS_PATH}/dev

# 如果是跨架构操作，确保 qemu-user-static 已经挂载
# if [ -e "/usr/bin/qemu-aarch64-static" ]; then
#     cp /usr/bin/qemu-aarch64-static "$ROOTFS_PATH/usr/bin/"
# fi

# 进入 chroot 环境
sudo chroot "$ROOTFS_PATH" /bin/bash

# 以下代码会在 chroot 环境中执行完毕退出后继续运行
echo "Exiting chroot, unmounting directories..."

# 卸载挂载的目录
sudo umount "$ROOTFS_PATH/proc"
sudo umount "$ROOTFS_PATH/sys"
sudo umount "$ROOTFS_PATH/dev"
# 如果有其他手动挂载的目录，也在这里添加相应的 umount 命令

# 如果之前复制了 qemu-user-static，则删除它，保持环境干净
# if [ -e "$ROOTFS_PATH/usr/bin/qemu-aarch64-static" ]; then
#     rm "$ROOTFS_PATH/usr/bin/qemu-aarch64-static"
# fi

echo "All done. File systems unmounted."

exit 0