# 天嵌 E9V3 开发板调试 LoRa 方法

Li Zheng <flyskywhy@gmail.com>

# 准备 NFS 方式运行环境
参考 [Linux开发板调试典型方法](Linux开发板调试典型方法.md) 启动 Linux。

# 准备编译环境
将 [天嵌 E9v3 卡片电脑下载资料](http://www.embedsky.com/index.php?g=home&m=download&a=show&id=7) 中 `TQIMX6_Linux平台工具` 里 gcc 的 bin 目录添加进主机 Linux 的 PATH 中即可。

# 使用 SPI 驱动操作 SPI 管脚
[天嵌 E9v3 卡片电脑下载资料](http://www.embedsky.com/index.php?g=home&m=download&a=show&id=7) 中， `Linux 4.1镜像` 里已经内含了 SPI 驱动，因此我们只需要按照 `配套教材集` 里的 《TQIMX6_E9硬件手册.pdf》 “扩展接口” 一章中用飞线短接 38 脚 CSPI2_MISO 和 39 脚 CSPI2_MOSI ，再用 `Linux4.1资源` 中的 `测试方法及示例代码/spi/build.sh` 在主机 Linux 中编译出 spi_test 可执行文件，就可以复制到 NFS 中进行本地 loopback 测试了。

一切正常的话，在开发板 Linux 中运行 `./spi_test  --verbose` 的输出应为
```
spi mode: 0x0
bits per word: 8
max speed: 500000 Hz (500 KHz)
TX | FF FF FF FF FF FF 40 00 00 00 00 95 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF F0 0D  | ......@....�..................�.
RX | FF FF FF FF FF FF 40 00 00 00 00 95 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF F0 0D  | ......@....�..................�.
```

# 使用 LoRa 驱动操作 SPI 管脚上的 LoRa 芯片
可以在 LoRa 应用或库中编写代码去操作上面的 SPI 驱动来达到操作 LoRa 芯片的目的，不过现在有直接的 LoRa 驱动 [https://github.com/starnight/LoRa/tree/file-ops](https://github.com/starnight/LoRa/tree/file-ops) 可使用。该 LoRa 驱动使用了 Linux 3.1 开始引入的用于减少慢速 I/O 驱动上的重复逻辑的 regmap 特性，所以如果你的 Linux 版本低于 3.1 的话，就只能使用上面的 SPI 驱动。

这里不使用 LoRa 驱动的 master 而是 file-ops 分支的原因是我们只想采用 ARM + LoRa 的网关与 STM32 + LoRa 的终端的通信方案，这样可以大大降低终端的成本，而 STM32 上是无法运行 Linux 的，所以 LoRa 驱动作者后来在 master 分支上想要达到的将 LoRa 作为自定义无线网卡的目标并不是我们的需求。具体可以翻墙参考 LoRa 驱动作者的 PPT [Let's Have an IEEE 802.15.4 over LoRa Linux Device Driver for IoT](https://www.slideshare.net/chienhungpan/lets-have-an-ieee-802154-over-lora-linux-device-driver-for-iot) 以及相关中文视频解说 [Let's Have an IEEE 802.15.4 over LoRa Linux Device Driver for IoT - YouTube](https://www.youtube.com/watch?v=_lGN-LDyl2I) ，从该解说中也可获知作者使用轮询中断标志位的方式替代了 GPIO 口连接 LoRa 的表明中断的 DIO 口，所以下文飞线时没有做 DIO 的连接处理。

## 编译 .dtb 文件
由于 `Linux4.1资源` 中的 `Linux 4.1源码/` 的由 `config_linux` 复制而成的 `.config` 里的 `CONFIG_OF_OVERLAY` 并未开启，所以无法按照 [用Device tree overlay掌控Beaglebone Black的硬件资源](https://techfantastic.wordpress.com/2013/11/15/beaglebone-black-device-tree-overlay/) 一文用类似 `echo BB-UART1 > /sys/devices/bone_capemgr.*/slots` 的语句来动态加载比如 LoRa 驱动源码 `https://github.com/starnight/LoRa` 中的 `dts-overlay/rpi-lora-spi-overlay.dts` 编译而成的 `.dtbo` 文件，而必须要重新编译出整个开发板的 `.dtb` 文件。

参考理解 [ARM 设备树](https://blog.csdn.net/21cnbao/article/details/8457546) 一文，将 `Linux 4.1源码/` 的 `arch/arm/boot/dts/imx6qdl-sabresd.dtsi` 中的
```
spidev0: spi@0 {
    compatible = "rohm,dh2228fv";
    reg = <0>;
    spi-max-frequency = <54000000>;
};
```
替换成
```
sx1278@0 {
    compatible = "sx1278";
    reg = <0>;
    spi-max-frequency = <0x3b60>;
    clock-frequency = <32000000>;
};
```
然后参考 `Linux 4.1源码/` 的 `build.sh` 内容，在主机 Linux 中运行如下语句
```
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
cp config_linux .config
make dtbs
```
即可得到新的 `arch/arm/boot/dts/imx6q-sabresd.dtb` 文件。再将此文件按照 [Linux开发板调试典型方法](Linux开发板调试典型方法.md) 所说重新下载到板子上，然后如果发现之前的 `./spi_test  --verbose` 会报错说 `can't open device` 或者是无法 `ls /dev/spidev1.0` 了，则说明我们已经成功地更新了 device tree 。

## 编译 .ko 文件
在主机 Linux 中进入 [https://github.com/starnight/LoRa/tree/file-ops](https://github.com/starnight/LoRa/tree/file-ops) 的 LoRa 目录，使用如下语句编译出 `sx1278.ko` ：
```
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export BUILDDIR=`Linux4.1资源` 中的 `Linux 4.1源码/` linux kernel 目录
make -C $BUILDDIR M=`pwd` modules
```
## 飞线 LoRa 芯片
按照 `配套教材集` 里的 《TQIMX6_E9硬件手册.pdf》 “扩展接口” 一章，用飞线连接：
```
38 脚 CSPI2_MISO -> LoRa 的 SO
39 脚 CSPI2_MOSI -> LoRa 的 SI
40 脚 CSPI2_CLK  -> LoRa 的 SCK
41 脚 CSPI2_CS0  -> LoRa 的 NSS
 8 脚 VDD_3V3    -> LoRa 的 VCC
 7 脚 GND        -> LoRa 的 GND
```
## 加载 .ko 文件
将 `sx1278.ko` 复制到 NFS 的 `lib/modules/4.1.15-1.0.0+g3924425/` 中后，先在开发板 Linux 中运行一次

    depmod -a

来自动修改 `lib/modules/4.1.15-1.0.0+g3924425/modules.*` 文件（由于之前没有 `make zImage` 编译过内核，这里可能需要先运行 `ln -s 4.1.15-1.0.0+g3924425 4.1.15`），这样今后就可以在开发板 Linux 的任意目录中运行

    modprobe sx1278

来加载该 .ko 驱动了（由于之前没有 `make zImage` 编译过内核，这里可能需要运行 `modprobe sx1278 -f`）。

如果一切正常的话，就可以看到终端中打印出

    sx1278 spi1.0: probe a LoRa SPI device with chip ver. 1.2

而且也能 `ls /dev/loraSPI1.0` 了。

如果没有在 spi 接口上连接 LoRa 芯片的话，也能在终端中看到 spi-sx1278.c 中的 `dev_err(&(spi->dev), "no LoRa SPI device, error: %d\n", status)` 打印。

其它的打印信息可以通过 `dmesg` 命令或是 `vi /var/log/dmesg` 或是 `vi /var/log/messages` 来查看。

如果之前没有正确修改过 .dtsi 的话，那些 dev_err 打印都不会出现，这是因为 kernel 如果运行 .ko 也就是驱动源码到比如 spi-sx1278.c 中 of_get_property() 语句的地方时，它没法从 .dtb 中查找到 spi-sx1278.c 的 .compatible 语句所表明的节点，也因此无法让 of_get_property() 获得节点中的 clock-frequency 内容，所以 kernel 根本就不会响应 modprobe 命令而去运行 .ko ，也因此根本就不会运行到 spi-sx1278.c 中的那些 dev_err 打印语句。

## 调试 .ko 文件
由于 `Linux4.1资源` 中的 `Linux 4.1源码/` 的由 `config_linux` 复制而成的 `.config` 里的 `CONFIG_DYNAMIC_DEBUG` 并未开启，影响到 `include/linux/printk.h` 里的宏定义行为会使得 LoRa 源码中的 pr_debug 不会打印出任何东西，所以如果想开启这些 LoRa 调试打印行为但并不想 `make zImage` 重新编译内核的话，比较取巧的方法是将 `include/linux/printk.h` 中的
```
#else
#define pr_debug(fmt, ...) \
	no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
#endif
```
修改为
```
#else
#define pr_debug(fmt, ...) \
	printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
#endif
```
然后重新编译 .ko 。

最后就可以随时在不修改 `include/linux/printk.h` 的情况下 [调整内核printk的打印级别](https://blog.csdn.net/tonywgx/article/details/17504001) ，比如使用

    echo 8 > /proc/sys/kernel/printk

来临时开启 pr_debug 的打印及

    echo 7 > /proc/sys/kernel/printk

来恢复默认的禁止 pr_debug 的打印级别配置。
