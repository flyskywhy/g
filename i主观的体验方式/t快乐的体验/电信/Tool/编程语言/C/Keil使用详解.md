Li Zheng <flyskywhy@gmail.com>

# Keil 使用详解

## 安装
### 安装主体软件
MDK(Keil) 软件试用版可以公开下载，无需付费，除非程序超过 32KB 。

### 按需安装 Packs
以华大 HC32F005 芯片为例，可以去华大半导体官网下载对应包，也可以在使用 MDK 打开一个现有工程时所弹出的对话框
```
Missing Device Information
The following Device Family Pack(s) are required by the project:
HDSC:HC32F005:1.0.1
```
中点击 Install ，就会自动弹出一个 `Pack Installer` 程序开始进行安装。

如果出现
```
Update project device(s)
Installation of Device Family Pack(s) failed.
```
再查看 `Pack Installer` 程序的状态栏中提示安装失败原因为

    Cannot download file https://raw.githubusercontent.com/hdscmcu/pack/master/HDSC.HC32F005.1.0.1.pack: Server or proxy not found

则需要想办法让 Windows 处于“科学上网”状态，然后再次安装。

安装完上面的包后， MDK 还会弹出另外一个对话框
```
Missing Software Packs
The following Software Packs are missing:
  ARM.CMSIS
required by the following project targets:
  project
Install missing Software Packs?
```
此时一般点击“否”，因为如果 CMSIS 的版本没装对的话，编译时会出现比如 `unknown compiler` 这样的错误。

比如在 `Pack Installer` 程序中手动安装比如 `ARM.CMSIS | Previous` 的 `5.9.0` 版本。

如果现有工程可以在 `ARM.CMSIS` 的 `5.9.0` 版本编译通过，但 `6.0.0` 不能，但又想使用 `6.0.0` 的，则可以参考 [KAN298 - Migrate from ARM C/C++ Compiler 5 to ARM Compiler 6](https://developer.arm.com/documentation/kan298/1-0) 。
