# Linux 开发板调试典型方法

Li Zheng <flyskywhy@gmail.com>

# 安装开发环境

## tftpd
    sudo apt-get install tftpd openbsd-inetd

将 `/etc/inetd.conf` 文件中的最后一个路径设置成你希望让客户端存取文件的目录，例如下面的 `/tftp` （记得开放该目录的读写权限）：

    tftp		dgram	udp	wait	nobody	/usr/sbin/tcpd	/usr/sbin/in.tftpd /tftp

然后用如下语句重启 tftpd 服务：

    /etc/init.d/openbsd-inetd restart

备注：可以使用 `tftp localhost` 进行 put 或 get 文件来测试 tftpd 是否运行正常。

## nfs-kernel-server
    sudo apt-get install nfs-kernel-server

在 `/etc/exports` 文件中添加一个路径，使之成为你希望让客户端挂载其中某个目录的目录，例如下面的语句：

    /nfs *(rw,insecure,sync,no_wdelay,no_subtree_check,insecure_locks,no_root_squash)

然后用如下语句重启 `nfs-kernel-server` 服务：

    /etc/init.d/nfs-kernel-server restart

备注：可以使用例如 `sudo mkdir /mnt/nfs ; sudo mount -t nfs 192.0.16.37:/nfs /mnt/nfs` 来测试 `nfs-kernel-server` 是否运行正常，测试完成后 `sudo umount /mnt/nfs` 。

## 串口调试软件
这里以命令行软件 minicom 为例，当然也可以使用图形化软件 gtkterm 或 putty ，看个人喜好。

使用 `minicom -s` 配置或者直接在 `/etc/minirc.dfl` 中添加如下内容：
```
# 机器生成的文件 - 使用 "minicom -s" 改变参数.
pu port             /dev/ttyS0
pu rtscts           No
```

注：如果用的是 USB 转串口设备，则用 ttyUSB0 替代 ttyS0 。

# 调试开发板
这里分别以 ARM 和 MIPS 开发板举例。

## ARM
这里以 [天嵌](http://www.embedsky.com) IMX6 开发板通过 NFS 运行 Linux 为例。
### Bootload
在终端启动 minicom ，上电开发板，开发板将会通过串口在 minicom 中打印 bootload 信息。

开发板上电后 1 秒内迅速在 minicom 中按下回车键进入 ARM 的 bootload 即 uboot 命令行界面（否则它会自动启动闪存中的 Android 系统），输入 ? 符号会打印出天嵌整理在 uboot 中可用的命令，输入如下命令让连接着路由器的开发板的网口自动获取IP地址：

    dhcp

它获得 IP 地址后就会自动尝试通过 tftp 启动，此时当然会报错，所以 `CTRL+C` 即可，因为我们这里只是用它来获得 IP 地址而已。

### Linux 内核
然后输入如下命令将主机上的 tftpd 目录（比如 `192.0.16.37` 上的 `/tftp` 目录）中来自于 [天嵌 E9v3 卡片电脑下载资料](http://www.embedsky.com/index.php?g=home&m=download&a=show&id=7) 中 `Linux 4.1镜像` 里的 Linux 内核文件 `zImage` 和 [ARM 设备树](https://blog.csdn.net/21cnbao/article/details/8457546) 文件 `imx6q-sabresd.dtb` 下载到开发板中：

    tftpboot 192.168.0.16.37:zImage
    tftpboot ${fdt_addr} 192.168.11.105:imx6q-sabresd.dtb

这里 ${fdt_addr} 不用关心，这是 uboot 中已经设好的环境变量（可以通过 `env print` 命令查看）。

### Linux 根文件系统
最后输入如下命令挂载主机上的 nfs 中的某个目录（比如 `192.0.16.37` 上的 `/nfs/rootfs_qt5` 目录）作为根文件系统并启动 Linux （下面的 `192.0.16.87` 是开发板之前在 Bootload 步骤中获得的 IP 地址）：

    setenv bootargs console=ttySAC0,115200 ip=192.0.16.87:192.0.16.37:192.0.16.1:255.255.255.0 init=/init root=/dev/nfs rootwait rw nfsroot=192.0.16.37:/nfs/rootfs_qt5,v3,tcp video=mxcfb0:dev=hdmi,1280x720@60,if=RGB24,bpp=32 video=mxcfb1:off video=mxcfb2:off video=mxcfb3:off vmalloc=400M androidboot.console=ttySAC0 androidboot.hardware=freescale cma=384M
    bootz ${loadaddr} - ${fdt_addr}

这里 bootz 的参数特别是 - 符号的意义可参见 `? bootz` 命令的输出。

### 天嵌开发板其它
新购开发板默认用 VGA 启动 Android ，如果想让它默认使用 HDMI ，可在 uboot 中使用 menu 命令打开菜单，然后 `setting boot args` | `setting display args` | `mxfb0 display args` | `hdmi` 保存退出重启即可。

## MIPS
这里以 Sigma smp86xx 开发板通过 NFS 运行 Android 为例。
### Bootload
在终端启动 minicom ，上电开发板，开发板将会通过串口在 minicom 中打印 bootload 信息。

在 MIPS 的 bootload 即 YAMON 启动后的界面中输入如下命令让连接着路由器的开发板的网口自动获取IP地址：

    net init

### Linux 内核
然后输入如下命令将主机上的 tftpd 目录（比如 `192.0.16.37` 上的 `/tftp` 目录）中的 Linux 内核文件 `vmlinux.bin` 下载到开发板中：

    load -b tftp://192.0.16.37/vmlinux.bin 0x84000000

### Android 根文件系统
最后输入如下命令挂载主机上的 nfs 中的某个目录（比如 `192.0.16.37` 上的 `/nfs/Sigma_rfs` 目录）作为根文件系统并启动 Linux （下面的 `192.0.16.87` 是开发板之前在 Bootload 步骤中获得的 IP 地址）：

    go . root=/dev/nfs nfsroot=192.0.16.37:/nfs/Sigma_rfs ip=192.0.16.87:192.0.16.37::::eth0:none: rdinit=/none init=/init console=ttyS0 mem=192M androidboot.hardware=smp86xx
