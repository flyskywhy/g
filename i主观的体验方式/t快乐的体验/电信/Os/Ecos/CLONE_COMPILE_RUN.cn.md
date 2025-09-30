Li Zheng flyskywhy@gmail.com

2013.06.25

# 0. $SHELL可能需要的准备

如果Linux中自己账户默认使用的SHELL不是bash，本文中使用的shell脚本运行可能会出错。鉴于bash在Linux世界中的通用性，建议除非必要，否则就将自己的账户设置为默认使用bash。

使用如下命令可以查看当前使用的SHELL类型：

    echo $SHELL

永久设置bash的方法是运行如下命令：

    chsh -s /bin/bash 你的Linux用户名

临时设置bash的方法是运行如下命令：

    /bin/bash


# 1. 在Windows下的准备

## 1.1 代码管理工具git

[http://code.google.com/p/msysgit/downloads/list](http://code.google.com/p/msysgit/downloads/list) 中下载

    msysGit-fullinstall-最新版.exe

安装好后确定`msysgit/etc/gitconfig`文件中的`autocrlf = false`，否则如果为true的话会导致各种问题。

### 1.1.1 msys终端窗口

运行安装好后的目录中的msys.bat就可开启带有git和mingw编译环境的终端窗口。

## 1.2 仿Linux环境工具cygwin

### 1.2.1 可以通过git来绿色安装cygwin

在msys终端中运行如下命令：

    cd /c/
    git clone https://github.com/flyskywhy/cygwin.git

然后在资源管理器中双击`C:/cygwin/green_install_1st_double_click.reg`

这样就可以通过运行`C:/Cygwin.bat`来进入cygwin终端窗口了。

最后在cygwin终端中运行如下命令：

    cd /cygdrive/c/cygwin/
    ./green_install_2nd_run_in_cygwin.sh

这样cygwin就完全安装好了。

### 1.2.2 可以通过setup.exe来安装cygwin

从[www.cygwin.com](www.cygwin.com)下载安装`setup.exe`，在setup安装界面的`Select Packages`页面中只要使Devel软件包的状态由Default变为Install即可进行cygwin的安装。

另外，由于从cygwin的`make.exe`的`3.81`版开始，make不再支持Windows的类似`C:`这样的路径，因此，为了能够让原生版（非cygwin版）编译器及定制版[ecos-tools](https://github.com/flyskywhy/ecos-tools.git)支持ecos，安装好标准cygwin后，还需要将`cygwin/bin/make.exe`替换成较老的`3.80`版，该版本可以在[http://geant4.cern.ch/support/extras/cygwin/make.exe](http://geant4.cern.ch/support/extras/cygwin/make.exe)下载。

### 1.2.3 cygwin终端窗口

运行安装好后的目录中的Cygwin.bat就可开启带有git和其它Linux编译环境的终端窗口。在Windows环境中，下文中的终端窗口如无特别指出，统指cygwin终端而非msys终端。

# 2. 代码下载

## 2.1 项目代码统一管理工具的下载

在终端窗口中运行如下命令：

    mkdir ecos
    cd ecos
    git clone https://github.com/flyskywhy/proj.git -b ecos

注意，这里的ecos指的是项目根目录，而非后续会由`proj clone`命令检出的ecos/ecos/目录，为免混淆，后续将以“项目根目录”指代该目录。

## 2.2 环境设置

在项目根目录中运行如下命令：

    source proj/env.sh

这里可能会报一些错误，这是因为env.sh中自动source的脚本语句无法source还未clone出的目录中的脚本文件，所以后文会出现再次运行`source proj/env.sh`的描述。

## 2.3 使用项目代码统一管理工具批量下载项目代码

在项目根目录中运行如下命令：

    proj clone

### 2.3.1 使用项目代码统一管理工具批量更新项目代码

可以进入某个含有.git/子目录的目录，然后使用`git fetch`来获取（本地工作文件不会改变）或是`git pull`来合并（本地工作文件会改变）中心仓库最新版本到本目录中。

也可以进入项目根目录，然后使用`proj fetch`来批量获取（本地工作文件不会改变）或是`proj pull`来批量合并（本地工作文件会改变）中心仓库最新版本到各个含有.git/子目录的子目录中。

## 2.4 目录结构说明

### 2.4.1 操作系统ecos子项目

    ecos/ecos/

### 2.4.2 应用程序ecos_app_base子项目

    ecos/apps/ecos_app_base/

其它的ecos应用项目可以此子项目为参考。

### 2.4.3 工具子项目

    ecos/tools/*/

### 2.4.4 microblaze硬件设计子项目

    ecos/mbref/


# 3. 软件设计

## 3.1 ecos-tools的编译

前述`proj clone`默认已经下载了tools/ecos-tools/这个由git管理的预编译好的目录，如果不想使用预编译好的工具而是想要自己编译的，则可按如下步骤操作:

### 3.1.1 环境设置

在项目根目录中运行如下命令：

    source proj/env.sh

- 如果是Linux：

        sudo apt-get install tcl tcl-dev automake autoconf texinfo tk tk-dev

- 如果是Windows:

    安装Cygwin时选中“Devel”，如果该版本的Cygwin中有单独列出“Tcl”的话则还需选中“Tcl”

### 3.1.2 编译

在项目根目录中运行如下命令（注意：这个tool脚本会自动删除ecos/tools/ecos-tools/目录然后再自动重建之，重建的时间比较长，所以这里再次强调一下，如果觉得原来的预编译好的工具可用的，就不要执行下面的命令了）：

    tool


## 3.2 ecos操作系统的编译

### 3.2.1 环境设置

在项目根目录中运行如下命令：

    source proj/env.sh

或是在类似ecos/apps/ecos_app_base/目录中运行如下命令：

    source ../../proj/env.sh

- 如果是Linux：

    如果使用的是预编译好的ecos/tools/ecos-tools/，则需要：

       sudo apt-get install libstdc++5

    如下步骤是依赖于预编译好的ecos/tools/ecos-tools/的：

        cp -a tools/ecos-tools/bin/.eCosPlatforms/ ~/

- 如果是Windows：

    如下步骤是依赖于预编译好的ecos/tools/ecos-tools/的：

    鼠标双击ecos/tools/ecos-tools/platforms.reg

### 3.2.2 配置

首先，如果想要能在configtool的图形界面中的右键菜单中出现帮助文件，则需要将ecos/htdocs/docs-latest/目录软链接或复制到ecos/ecos/doc/中并使之更名为ecos/ecos/doc/html/目录，这样，在后续启动configtool之时，configtool会自动在ecos/ecos/目录中生成eCos.hhc和eCos.hhp这两个帮助功能所需要的文件。

在ecos/apps/ecos_app_base/之类的应用程序目录中运行如下命令：

    configtool ecos_avnet_s6lx9_mmu_tiny_13_1.ecc

或

    configtool ecos_malta.ecc

就可以在configtool的图形界面中对配置做一下微调。

- 比如想不使用redboot来下载并启动应用程序、而是使用JTAG直接下载并启动应用程序，则需要取消勾选`eCos HAL->Rom monitor support->Work with a ROM monitor`。
- 比如想在不使用redboot来下载并启动应用程序、而是使用JTAG直接下载并启动应用程序的情况下，diag_printf()或printf()也能够打印信息，则需要勾选`eCos HAL->Source-level debugging support->Include GDB stubs in HAL`。

#### 3.2.2.1 Xilinx FPGA开发板.ecc的由来

在`Build->Templates->Hardware`中设置Hardware为

    Avnet S6LX9 MMU tiny 13.1

设置Packages为

    net

在`Tools->Paths->Build Tools...`中设置为

    $PROJ_ROOT/tools/microblazeel-unknown-linux-gnu/bin

最后点击`File->Save As...`保存为ecos_avnet_s6lx9_mmu_tiny_13_1.ecc这个配置文件，此时会自动生成ecos_avnet_s6lx9_mmu_tiny_13_1_build/和ecos_avnet_s6lx9_mmu_tiny_13_1_install/两个目录。

#### 3.2.2.2 MIPS开发板.ecc的由来

在`Build->Templates->Hardware`中设置Hardware为

    MIPS Malta board with Mips32 4Kc processor

设置Packages为

    net

在`Tools->Paths->Build Tools...`中设置为

    ecos/tools/mipsisa32-elf

最后点击`File->Save As...`保存为ecos_malta.ecc这个配置文件，此时会自动生成ecos_malta_build/和ecos_malta_install/两个目录。

### 3.2.3 编译

在configtool的图形界面中：

点击`Build->Library`

此时就会生成ecos_*_install/lib/中相应的库文件

如果编译出错，可以尝试手动删除ecos_*_build/和ecos_*_install/两个目录然后
点击`Build->Generate Build Tree`

再点击`Build->Library`

## 3.3 ecos应用程序的编译

### 3.3.1 环境设置

在项目根目录中运行如下命令：

    source proj/env.sh

或是在类似ecos/apps/ecos_app_base/目录中运行如下命令：

    source ../../proj/env.sh


### 3.3.2 编译

在ecos/apps/ecos_app_base/之类的应用程序目录中运行如下命令：

    lunch

lunch命令会列出本目录中所有的.ecc文件，请选择与前述ecos配置相同的项。后续如果没有关闭当前的终端窗口，就无需再次运行本命令。后续如果通过lunch命令切换了.ecc文件，则在后续第一次make前需要`make clean`一下。

接着运行如下命令：

    make

此时就会生成链接了ecos库文件的可执行文件。

注意：如果是Windows下，而且如果编译器是原生版（非cygwin版），而且如果这里的Makefile中定义了变量`MY_LIBS_TO_GEN`且编译有错（比如libfreetype的源代码在这种情况下会有编译错误）的话，解决方法是在cygwin和msys的终端窗口中来回切换并运行make，如此这般切换几次后即可编译成功。

这里的Makefile使用了[万能Makefile](https://github.com/flyskywhy/makefile.git)功能，因此你增删`.c`文件后都不需要再去修改Makefile，除非你要增加自己的某个CFLAGS到应用程序的Makefile中而不是到configtool的`Global build options->Global compiler flags`中。

## 3.4 ecos应用程序在eclipse中的开发

在Xilinx xsdk之类的eclipse中`File->Import->General->Existing Projects into Workspace`选择ecos/apps/ecos_app_base/之类的应用程序目录，然后就可以在eclipse中进行编译等操作了。

这是因为再早之前我已经在比如ecos/apps/ecos_app_base/目录做了如下操作：

在eclipse中`File->New->Project->C Project`中的`Project name`处填入ecos_app_base，在`Makefile project`中选择`Empty Project`。

## 3.5 ecos应用程序的运行

### 3.5.1 Xilinx FPGA开发板

#### 3.5.1.1 配置JTAG连接

如果使用了[www.digilentinc.com](www.digilentinc.com)的USB JTAG，需要在Xilinx xsdk中`Xilinx Tools->Configure JTAG Settings`对话框中的`Type`选择`3rd Party Cable, Xilinx Plug-in`，然后在`Other Options`中输入`-cable type xilinx_plugin modulename digilent_plugin`。

#### 3.5.1.2 通过JTAG下载bit文件

在Xilinx xsdk中使用`Xilinx Tools->Program FPGA`。

#### 3.5.1.3 通过JTAG图形界面下载、运行ecos应用程序（操作较简单，但是下载时间较长）

在Xilinx xsdk中使用`Run->Debug Configurations`对话框中的`Xilinx C/C++ ELF`->你自己取的Name，如果需要打印而不想另外开启putty等终端工具，则在该对话框中的`STDIO Connection`处选中`Connect STDIO to Console`即可在xsdk的Console窗口中看到打印信息了。

##### 3.5.1.3.1

在Linux中使用xsdk如上所述调试时如果出现如下错误：

    ERROR : Unexpected error while launching program. java.lang.RuntimeException: Error creating session
    	at com.xilinx.sdk.debug.core.XilinxAppLaunchConfigurationDelegate.debugApplication(Unknown Source)
    	at com.xilinx.sdk.debug.core.XilinxAppLaunchConfigurationDelegate.launch(Unknown Source)

而且到命令行运行`mb-gdb`确认会出现如下错误的话：

    mb-gdb: error while loading shared libraries: libexpat.so.0: cannot open shared object file: No such file or directory

就按如下方法解决：

    cd /lib
    sudo ln -s libexpat.so.1 libexpat.so.0

#### 3.5.1.4 通过JTAG命令行界面下载、运行ecos应用程序（操作较复杂，但是下载时间较短）

在Xilinx xsdk中的`XMD Console`窗口或是自己在终端窗口里用`xmd`命令打开的窗口中，如果使用了[www.digilentinc.com](www.digilentinc.com)的USB JTAG，则首先通过如下命令来连接该JTAG：

    connect mb mdm -cable type xilinx_plugin modulename digilent_plugin

否则只需如下命令即可：

    connect mb mdm

然后通过如下命令来下载ecos应用程序：

    dow path/to/ecos_app_elf_file

打开xsdk中的`Terminal 1`窗口以便输出打印信息或是输入ecos应用程序所需的命令。

- 最后通过如下命令来运行：

    run

- 通过如下命令来停止以便运行新的dow命令：

    stop

- 可以通过如下命令来查看帮助：

    help

###3.5.2 在MIPS开发板上运行

请自行参照MIPS开发板运行、调试elf文件的方法。

# 4. 硬件设计

## 4.1 Xilinx FPGA开发板

硬件开发人员可参考如下目录进行新项目的迭代开发：

    ecos/mbref/working-designs/Avnet-S6LX9-MMU-tiny-13.1


# 5. i386虚拟机开发ecos应用程序

在开发板上ecos操作系统还没有移植好的情况下，应用开发人员可以在ecos自带的i386虚拟机环境中同步进行应用程序开发。

## 5.1 redboot

### 5.1.1 redboot的编译

在configtool中，

- 设置`Hardware`为

    i386 PC target (vmWare)

- 设置`Packages`为

    redboot

- 增加`Packages`：

    Common ethernet suppport

- 设置`eCos HAL->i386 architecture->i386 PC Target->Startup type`为

    FLOPPY

如果不想每次启动redboot后还要敲入如下命令

    ip_address -h 主机电脑的ip地址

才能使得`load`命令能从tftp下载elf文件，则可以设置`Redboot ROM monitor->Build Redboot ROM ELF image->RedbootNetworking->Default IP address->Default bootp server`为主机电脑的ip地址（注意，这里的ip地址不是用点号而是用逗号分隔的）。

最后`File->Save As...`保存为redboot_pc_vmWare.ecc再`Build->Library`即可得到redboot_pc_vmWare_install/bin/redboot.bin，然后用如下命令将之转换成虚拟机可用的软盘镜像：

    dd if=/dev/zero of=redboot.img bs=512 count=2880
    dd if=redboot.bin of=redboot.img conv=notrunc

如果是在Windows下比如Cygwin中，则可执行如下命令：

    dd conv=sync if=redboot.bin of=redboot.img（或是.flp类型） bs=1440k

### 5.1.2 redboot的运行

在虚拟机软件比如VirtualBox中新建一个操作系统和版本皆为Other的虚拟机，在该虚拟机的配置中的介质那里新建软盘控制器，然后在新建软盘的操作中将上面生成的redboot.img注册到VirtualBox中成为虚拟软盘。

开始运行后即可看到redboot的命令行界面。输入help可得redboot的命令帮助。

## 5.2 ecos操作系统的编译

在configtool中，设置`Hardware`为`i386 PC target (vmWare)`、设置`Packages`为`net`，保存为ecos_pc_vmWare.ecc编译即可。

## 5.3 ecos应用程序

### 5.3.1 ecos应用程序的编译

与前述`3.3 ecos应用程序的编译`相同。

### 5.3.2 ecos应用程序的运行

在redboot中下载elf文件：

    load elf文件

在redboot中运行elf文件：

    go



# 附录：代码整理过程以备后续更新

- 使用了如下命令下载了将hg仓库转成git仓库的工具：

        git clone https://github.com/offbytwo/git-hg.git

- 使用了如下命令下载了ecos的代码：

        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/ecos
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/ecos-v2_0-branch
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/ecos-v3_0-branch
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/flash_v2
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/images
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/nand-ecoscentric
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/yaffs-ecoscentric-gpl

- 使用了如下命令下载了编译ecos-tools所需的代码：

        git clone https://github.com/wxWidgets/wxWidgets.git


- 使用了如下命令下载了将cvs仓库转成git仓库的工具：

        sudo apt-get install git-cvs

- 使用了如下命令下载了ecos的代码，最后发现还是hg仓库中的代码比较合适，因此下列代码被废弃：

        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos ecos
        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos ecos/host
        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos ecos-opt
        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos htdocs

- 在ecos目录使用了如下命令来将参考用的一些`3.0 release`版本的代码转换成`current`版本以便干净地放入git仓库中做比对：

        find . -name v3_0 -type d | xargs rename "s/v3_0/current/"
        find . -name *.ecm | xargs sed -i "s/v3_0/current/g"

- 在ecos目录使用了如下命令来将参考用的一些`2.0 release`版本的代码转换成`current`版本以便干净地放入git仓库中做比对：

        find . -name v2_0 -type d | xargs rename "s/v2_0/current/"
        find packages/templates -name v2_0.ect -type f | xargs rename "s/v2_0/current/"
        find packages/templates -name *.ect | xargs sed -i "s/v2_0/current/g"
        find packages -name *.ecm | xargs sed -i "s/v2_0/current/g"

- 在ecos目录使用了如下命令来去除参考用的代码的文件权限差异以便干净地放入git仓库中做比对：

        git diff --summary | grep --color 'mode change 100755 => 100644' | cut -d' ' -f7- | xargs -d'\n' chmod +x
        git diff --summary | grep --color 'mode change 100644 => 100755' | cut -d' ' -f7- | xargs -d'\n' chmod -x

- 使用了如下命令将.cvsignore更名成.gitignore：

        find . -name ".cvsignore" | xargs rename "s/cvs/git/"
