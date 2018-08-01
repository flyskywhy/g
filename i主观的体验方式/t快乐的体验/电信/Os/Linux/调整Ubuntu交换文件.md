Li Zheng <flyskywhy@gmail.com>

# 调整 Ubuntu 交换文件
现在的 Ubuntu 默认安装时的交换文件为 2GB 左右，而有些软件比如 [nodec](https://github.com/pmq20/node-packer) 需要 10GB 左右的交换空间，此时就需要给 Ubuntu 设定一个更大的交换文件。

## 查看原来的 swapfile 文件大小

    ls -l /swapfile

## 创建一个比如 16GB 的空文件 swap16g

    sudo dd if=/dev/zero of=/swap16g bs=1G count=16

注：可以先用 `df` 命令查看挂载点 `/` 也就是根目录的可用空间是否足够放进一个 16GB 的文件。

## 创建 swap 文件系统

    sudo chmod 600 /swap16g
    sudo mkswap -f /swap16g

## 开启 swap16g

    sudo swapon /swap16g

## 设置开机启动

    sudo vim /etc/fstab

将里面的 swapfile 改为 swap16g

如果里面没有 swapfile 的，则添加格式为：
```
/swap16g                                 none            swap sw              0       0
```
## 关闭和删除原来的 swapfile

    sudo swapoff /swapfile
    sudo rm /swapfile
