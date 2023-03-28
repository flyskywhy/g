Li Zheng <flyskywhy@gmail.com>

# Lichee RV 使用详解

### 在 x86 Windows 上烧录 risc-v Linux 到 SD 卡
插上 SD 卡，用 Debian 镜像[烧录系统](https://wiki.sipeed.com/hardware/zh/lichee/RV/flash.html)。

### 在 x86 Linux 上修复 SD 卡中的分区
后面运行 risc-v Linux 时用`df -h`命令会发现根分区只有`3.6GB`，为避免后续安装更多软件时出现`No space left on device`，需使用 GParted 打开 SD 卡，在里面的 rootfs 上“右键菜单->信息”，根据提示“分区->检查”来扩大文件系统至整个`8GB`的分区。

### 运行 risc-v Linux
插上 HDMI 和 USB 键盘，使用用户名 root 和密码 licheepi 登录系统。

如果没有 USB HUB 来同时插上 USB 鼠标，则可使用`CTRL+ESC`来打开系统菜单找到终端程序。

在终端程序中`vi /etc/ssh/sshd_config`然后添加`PermitRootLogin yes`以解决无法以 root 账号 ssh 的问题，如此就可以拔下 HDMI 和 USB 键盘了。

`vi /etc/apt/sources.list`然后修改为如下

    #deb http://ftp.ports.debian.org/debian-ports/ sid main
    deb http://deb.debian.org/debian-ports sid main
    deb http://deb.debian.org/debian-ports unreleased main
    deb-src http://deb.debian.org/debian sid main

再参考 <https://www.ports.debian.org/archive> ，运行

    gpg --keyserver http://keyserver.ubuntu.com --recv-keys 01C2D6F3D1A46AD1C0DC2F3D8D69674688B6CB36
    gpg --export 01C2D6F3D1A46AD1C0DC2F3D8D69674688B6CB36 | apt-key add -

这样就可以顺利`apt update`了，而且隔上几天了就要先`apt update`，否则在`apt install`时很容易`404`。

## 在 x86 Linux 上安装`riscv64-unknown-linux-gnu-gcc`

    git clone https://github.com/riscv-collab/riscv-gnu-toolchain
    cd riscv-gnu-toolchain
    ./configure --prefix=/opt/riscv
    make linux

## 在 risc-v Linux 上运行 go + c 程序
比如编译 <https://github.com/flyskywhy/textiot/commit/046914e> ，然后在 risc-v Linux 上运行时如果出现没头没脑的`Segmentation fault`，则

    apt install gdb
    gdb textile-riscv
    run

就可以看到较详细的`SIGSEGV, Segmentation fault. transcmp at dcigettext.c:290`，分析判断是编译器问题，就进入`riscv-gnu-toolchain/glibc/`进行`git reset hard`到`2.37`版(注：`riscv-gnu-toolchain`也已在`2023-02-19`的提交点中更改为了`2.37`版)，然后重新`make linux`编译出编译器，再以之编译程序后运行就正常了。

## 在 risc-v Linux 上运行 js 程序

    apt install nodejs npm

然后就可以进行 nodejs 开发了，比如`npx http-server some_www_folder`就可以将 Lichee RV 作为一个 Web 服务器来使用了。
