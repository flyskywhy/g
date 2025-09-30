Li Zheng flyskywhy@gmail.com

# mips 仿真器 gdb 调试方法

# 1. 开启终端，进入 `.elf` 文件所在的文件夹
比如类似 `apps/ecos_app_base/` 这样的路径

# 2. 设置 PATH
将 `tools/mips-sde-elf-4.2-199/bin/` 添加到路径中，或者如果存在类似 `proj/env.sh` 这样的文件的话，运行如下命令即可：

    source ../../proj/env.sh

# 3. 添加 `.gdbinit` 文件
在 `.elf` 文件所在的文件夹中添加 `.gdbinit` 文本文件，文件的内容根据两种情况而有所不同：

## 3.1. 软件 MIPS Sim ：

    set endian little
    set mdi library libMIPSsim_MDI.so
    target mdi 1:1
    file ecos_app_base.elf
    load

（注： `libMIPSsim_MDI.so` 的 Windows 版本是 `MIPSsim_MDI.dll` ）

这里 `1:1` 的意思是 `mips-single-core` ，其他组合可在 `mips-sde-elf-gdb` 的 Console 中运行 `show mdi devices` 来获知。

## 3.2. 硬件 MIPS ：

    set endian little
    set mdi library libjnetfs2mdimips.so
    target mdi 1:1
    file ecos_app_base.elf
    load

（注：类似 `libjnetfs2mdimips.so` 的 Windows 版本是 `jnetfs2mdilibmips.so` 。如果是使用 `MIPS ICS` 中软件，则这里是 `libsysnav_mdi.so` 。类似 `libsysnav_mdi.so` 的 Windows 版本是 `sysnav_mdi.dll` ）

# 4. 运行 gdb
在 `.elf` 文件所在的文件夹中运行如下命令：

    mips-sde-elf-gdb

在弹出 FS2 的 sysnav 的对话框并点击 OK 后， `.elf` 文件就会被下载，然后就可以运行 gdb 的命令比如 run 进行全速运行。

# 5. 整合进 Eclipse 中

在 `.elf` 文件所在的文件夹中运行如下命令：

    eclipse

对已有的源代码进行简单的 Eclipse 工程管理后，然后就可以在新建的工程比如 ecos_app_base 上右键菜单 | Debug As | Debug Configurations 对话框中，双击 `C/C++ Application` ，然后在 Main 页的 `C/C++ Application` 中填入比如 `ecos_app_base.elf` ，在 Debugger 页的 `GDB Debugger` 中填入 `mips-sde-elf-gdb` ，在 `GDB command file` 中填入 `.gdbinit` 。

然后就可以在 Eclipse 中进行断点调试等等操作了。
