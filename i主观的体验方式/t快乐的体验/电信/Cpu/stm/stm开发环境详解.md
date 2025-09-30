Li Zheng flyskywhy@gmail.com

# stm 开发环境详解

https://github.com/gicking/STM8-SPL_SDCC_patch

如果是在 [sdcc 官网](http://sdcc.sourceforge.net/) 下载的，运行时如果出现类似

    version `GLIBC_2.29' not found

这样的提示，则说明当前 Linux Ubuntu 版本太低，此时可以简单使用

sudo apt-get install sdcc sdcc-doc sdcc-libraries sdcc-ucsim

来安装一个稍低版本的 sdcc 。

```
git clone https://github.com/vdudouyt/stm8flash.git
cd stm8flash
sudo apt-get install libusb-1.0-0-dev
make
```
添加 `/etc/udev/rules.d/49-stlinkv2.rules`文件：
```
# stm32 discovery boards, with onboard st/linkv2
# ie, STM32L, STM32F4.
# STM32VL has st/linkv1, which is quite different

SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
    MODE:="0666", \
    SYMLINK+="stlinkv2_%n"

SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    KERNEL!="sd*", KERNEL!="sg*", KERNEL!="tty*", SUBSYSTEM!="bsg", \
    MODE:="0666", \
    SYMLINK+="stlinkv2_%n"

SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    KERNEL=="sd*", MODE:="0666", \
    SYMLINK+="stlinkv2_disk"

SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    KERNEL=="sg*", MODE:="0666", \
    SYMLINK+="stlinkv2_raw_scsi"

SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    SUBSYSTEM=="bsg", MODE:="0666", \
    SYMLINK+="stlinkv2_block_scsi"

SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    KERNEL=="tty*", MODE:="0666", \
    SYMLINK+="stlinkv2_console"

# If you share your linux system with other users, or just don't like the
# idea of write permission for everybody, you can replace MODE:="0666" with
# OWNER:="yourusername" to create the device owned by you, or with
# GROUP:="somegroupname" and control access using standard unix groups.
```
然后重新拔插 USB

如果出现 `Tries exceeded` 的错误，有各种原因：

1. 如果是 STM8L 的，则参见 [Stlinkv2 stm8l unlock](https://github.com/vdudouyt/stm8flash/pull/98) ，使用 https://github.com/sjborley/stm8flash/tree/stlink-stm8L-unlock 的代码，然后

    stm8flash -c stlinkv2 -p stm8l052r8 -u

即可进行后续的烧录行为比如

    stm8flash -c stlinkv2 -p stm8l052r8 -w stm8flash -c stlinkv2 -p stm8l052r8

2. 其它情况参考 [stm8s103f3 flashing - Tries exceed - Protected chip](https://github.com/vdudouyt/stm8flash/issues/38) 自行寻找解决方式。
