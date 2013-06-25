Li Zheng <flyskywhy@gmail.com>

2013.06.25

# 0. $SHELL may need to prepare

If the SHELL used by default in your Linux account is not bash, shell scripts used in this document may run fail. Given bash in the Linux world's versatility, it is recommended unless absolutely necessary, otherwise your account will be set as the default to use bash.

Use the following command to view the current SHELL type:

    echo $SHELL

Permanently set bash method is to run the following command:

    chsh -s /bin/bash YourLinuxUsername

Temporarily set bash method is to run the following command:

    /bin/bash


# 1. Prepared under Windows

## 1.1 Git the code management tool

In [http://code.google.com/p/msysgit/downloads/list](http://code.google.com/p/msysgit/downloads/list), download

    msysGit-fullinstall-LatestVersion.exe

After installation, determine `autocrlf = false` in the `msysgit/etc/gitconfig` file, or if it is true it will lead to various problems.

### 1.1.1 msys terminal window

Running msys.bat in the installation directory will open a terminal window with git and mingw compiler environment.

## 1.2 Cygwin the Linux environment imitation tool

### 1.2.1 Can green install cygwin by git

In msys terminal, run the following command:

    cd /c/
    git clone https://github.com/flyskywhy/cygwin.git

Then double-click `C:/cygwin/green_install_1st_double_click.reg` in Explorer.

So that you can run `C:/Cygwin.bat` to enter cygwin terminal window.

Finally, in cygwin terminal, run the following command:

    cd /cygdrive/c/cygwin/
    ./green_install_2nd_run_in_cygwin.sh

Such cygwin is completely installed now.

### 1.2.2 Can install cygwin by setup.exe

Download and install `setup.exe` from [www.cygwin.com](www.cygwin.com), Just switch the state of Devel package from Default to Install in the `Select Packages` page of setup installation interface, then can carried out the installation of cygwin.

In addition, because cygwin's `make.exe` from `3.81` version of the beginning, make no longer supports Windows path similar to `C:`, so, in order to let the native version (non-cygwin version) compiler and a customized version of the [ecos-tools](https://github.com/flyskywhy/ecos-tools.git) support ecos, after standard cygwin installation, you also need to replace `cygwin/bin/make.exe` with `3.80 ` the older version, this version can download from [http://geant4.cern.ch/support/extras/cygwin/make.exe](http://geant4.cern.ch / support / extras / cygwin / make.exe).

### 1.2.3 cygwin terminal window

Running Cygwin.bat in the installation directory will open a terminal window with git and other Linux compiler environment. In a Windows environment, the terminal window without special below collectively refers to the cygwin terminal rather than msys terminal.

# 2. CLONE

## 2.1 Download the project code unified management tool

In the terminal window, run the following command:

    mkdir ecos
    cd ecos
    git clone https://github.com/flyskywhy/proj.git -b ecos

Note that the ecos here refers to the root directory of the project, rather than the ecos/ecos/ directory checked out by `proj clone` command follow, to avoid confusion, the follow-up will be "project root directory" to refer to the directory.

## 2.2 Environment settings

In the project root directory, run the following command:

    source proj/env.sh

Some errors may be reported here, it is because the automatic source script statements in env.sh can not source the script file in the directory that has not been cloned, so the text will descript to run `source proj/env.sh` again.

## 2.3 Batch clone project code by the project code unified management tool

In the project root directory, run the following command:

    proj clone

### 2.3.1 Batch update project code by the project code unified management tool

You can enter a directory that contain a .git/ subdirectory, then use `git fetch` to get (local working file will not be changed) or `git pull` to merge (local working file will be changed) the latest version of the central repository to current directory.

You can also enter the project root directory, and then use `proj fetch` to batch get (local working file will not be changed) or `proj pull` to batch merge (local working file will be changed) the latest version central repository to each subdirectory which contain .git/ subdirectory.

## 2.4 Directory structure description

### 2.4.1 Operating system ecos subproject

    ecos/ecos/

### 2.4.2 Application ecos_app_base subproject

    ecos/apps/ecos_app_base/

Other ecos application projects can reference this subproject.

### 2.4.3 Tool subproject

    ecos/tools/*/

### 2.4.4 Microblaze hardware design subproject

    ecos/mbref/


# 3. Software design

## 3.1 COMPILE ecos-tools

By default, aforementioned `proj clone` have downloaded a precompiled directory tools/ecos-tools/ managed by git, if you do not use the precompiled tools but want compile them by yourself, you can press the following steps:

### 3.1.1 Environment settings

In the project root directory, run the following command:

    source proj/env.sh

- If it is Linux:

        sudo apt-get install tcl tcl-dev automake autoconf texinfo tk tk-dev

- If it is Windows:

    Selected "Devel" when installing Cygwin, if that version of Cygwin has singled out "Tcl", then you also need to select the "Tcl"

### 3.1.2 Compile

In the project root directory, run the following command (Note: This tool script will automatically delete ecos/tools/ecos-tools/ directory and then automatically reconstruct it, reconstruction of a long time, so here Again, if you feel that the original pre-compiled tools are available, do not execute the following commands):

    tool


## 3.2 COMPILE ecos the operating system

### 3.2.1 Environment settings

In the project root directory, run the following command:

    source proj/env.sh

Or in similar ecos/apps/ecos_app_base/ directory, run the following command:

    source ../../proj/env.sh

- If it is Linux:

    If you are using the precompiled ecos/tools/ecos-tools/, you will need:

        sudo apt-get install libstdc++5

    The following steps are dependent on the precompiled ecos/tools/ecos-tools/:

        cp -a tools/ecos-tools/bin/.eCosPlatforms/ ~/

- If it is Windows:

    The following steps are dependent on the precompiled ecos/tools/ecos-tools/:

    Double click ecos/tools/ecos-tools/platforms.reg

### 3.2.2 Configuration

First, if you want to have right-click menu help file in configtool's graphical interface, you will need to let ecos/htdocs/docs-latest/ directory soft link or copy to ecos/ecos/doc/ and then rename to ecos/ecos/doc/html/ directory, so that at the time of follow-up launch configtool, configtool will automatically generate eCos.hhc and eCos.hhp these two files needed by help function in ecos/ecos/ directory.

In ecos/apps/ecos_app_base/ kind of application directory run the following command:

    configtool ecos_avnet_s6lx9_mmu_tiny_13_1.ecc

Or

    configtool ecos_malta.ecc

You can do some fine-tuning on configuring in configtool graphical interface.

- For example does not want to use redboot to download and launch the application, but the use of JTAG directly download and launch the application, you need to uncheck `eCos HAL->Rom monitor support->Work with a ROM monitor`.
- Such as not using redboot to download and launch the application, but the use of JTAG download and launch applications directly to the case, still want diag_printf() or printf() can print information, you need to check the `eCos HAL->Source-level debugging support->Include GDB stubs in HAL`.

#### 3.2.2.1 the origin of Xilinx FPGA development board .ecc

In `Build->Templates->Hardware`, set Hardware to

    Avnet S6LX9 MMU tiny 13.1

set Packages to

    net

In `Tools->Paths->Build Tools...`, set to

    $PROJ_ROOT/tools/microblazeel-unknown-linux-gnu/bin

Finally, click on `File->Save As...` to save as a configuration file called ecos_avnet_s6lx9_mmu_tiny_13_1.ecc, then two directories called ecos_avnet_s6lx9_mmu_tiny_13_1_build/ and ecos_avnet_s6lx9_mmu_tiny_13_1_install/ will be automatically generated.

#### 3.2.2.2 the origin of MIPS development board .ecc

In `Build->Templates->Hardware`, set Hardware to

    MIPS Malta board with Mips32 4Kc processor

Set Packages to

    net

In `Tools->Paths->Build Tools...`, set to

    ecos/tools/mipsisa32-elf

Finally, click on `File-> Save As ...` to save as a configuration file called ecos_malta.ecc, then two directories called ecos_malta_build/ and ecos_malta_install/ will be automatically generated.

### 3.2.3 Compile

In configtool graphical interface:

Click on `Build->Library`

At this point it will generate corresponding library files in ecos_*_install/lib/

If compile error, you can try to manually remove ecos_\*_build/ and ecos\_*_install/ two directories and then
Click on `Build->Generate Build Tree`

Then click on `Build->Library`

## 3.3 COMPILE ecos application

### 3.3.1 Environment settings

In the project root directory, run the following command:

    source proj/env.sh

Or in similar ecos/apps/ecos_app_base/ directory, run the following command:

    source ../../proj/env.sh


### 3.3.2 Compile

In ecos/apps/ecos_app_base/ kind of application directory run the following command:

    lunch

lunch command will lists all .ecc file in current directory, select the  item that same with the aforementioned ecos configuration. If there is no follow-up to close the current terminal window, no need to re-run the command. If you switch .ecc file again by lunch command, `make clean` is needed before first make.

Then run the following command:

    make

At this point it will generate an executable file which links ecos library files.

Note: If you are under Windows, and if the compiler is a native version (non-cygwin version), but if the Makefile here defines the variables `MY_LIBS_TO_GEN` and compile error (for example libfreetype source code will compile error in this case), then the solution is to switch back and forth and run make in cygwin and msys terminal window, so it goes to switch a few times to compile successfully.

The Makefile here uses function from [Generic Makefile](https://github.com/flyskywhy/makefile.git), so you do not need to modify the Makefile after you add or delete `.c` files, unless you want to add one of your own CFLAGS to this application's Makefile instead of to the `Global build options->Global compiler flags` in configtool.

## 3.4 ecos application development in eclipse

In Xilinx xsdk like eclipse `File->Import->General->Existing Projects into Workspace`, select ecos/apps/ecos_app_base/ kind of application directory, then you can compile and do other operations in eclipse.

This is because I've done the following operations early in ecos/apps/ecos_app_base/ directory:

At `Project name` of eclipse `File->New->Project->C Project`, fill ecos_app_base, at `Makefile project`, select `Empty Project`.

## 3.5 RUN ecos application

### 3.5.1 Xilinx FPGA development board

#### 3.5.1.1 configure JTAG connection

If you use the USB JTAG from [www.digilentinc.com](www.digilentinc.com), In Xilinx xsdk, you need select `3rd Party Cable, Xilinx Plug-in` at `Type` in `Xilinx Tools->Configure JTAG Settings` dialog, then type `-cable type xilinx_plugin modulename digilent_plugin` at `Other Options`.

#### 3.5.1.2 download bit file via JTAG

In Xilinx xsdk, using `Xilinx Tools->Program FPGA`.

#### 3.5.1.3 download and run ecos application via JTAG graphical interface (operation is relatively simple, but the download time is longer)

In Xilinx xsdk, using `Xilinx C/C++ ELF`->"Name taken by you" in `Run->Debug Configurations` dialog, if you need to print and do not want to open another putty or other terminal tools, you need select `Connect STDIO to Console` at `STDIO Connection` in the dialog box, then you can see the print information in the Console window of xsdk.

##### 3.5.1.3.1

When debug in Linux by xsdk as described above, if get the following error:

    ERROR: Unexpected error while launching program. Java.lang.RuntimeException: Error creating session
    at com.xilinx.sdk.debug.core.XilinxAppLaunchConfigurationDelegate.debugApplication (Unknown Source)
    at com.xilinx.sdk.debug.core.XilinxAppLaunchConfigurationDelegate.launch (Unknown Source)

And confirm the following error when run `mb-gdb` in the command line:

    mb-gdb: error while loading shared libraries: libexpat.so.0: cannot open shared object file: No such file or directory

On the following solution:

    cd /lib
    sudo ln -s libexpat.so.1 libexpat.so.0

#### 3.5.1.4 download and run ecos application via the JTAG command line interface (operation is more complex, but the download time is shorter)

In the `XMD Console` window of Xilinx xsdk or in a terminal window after run `xmd` command, if you use the USB JTAG from [www.digilentinc.com](www.digilentinc.com), you should connect to the JTAG by the following command at first:

    connect mb mdm -cable type xilinx_plugin modulename digilent_plugin

otherwise, just following command:

    connect mb mdm

Then using the following command to download ecos application:

    dow path/to/ecos_app_elf_file

Open the `Terminal 1` window of xsdk to see the output print information or enter the command desired by the ecos application.

- Finally, run the following command:

        run

- Run the following command to stop in order to run a new dow command:

        stop

- Can use the following command to view the help:

        help

### 3.5.2 Running on MIPS development board

Please refer to MIPS development board run, debug elf files.

# 4. Hardware design

## 4.1 Xilinx FPGA development board

Hardware developers may iterative develop new projects refer to the following directory:

    ecos/mbref/working-designs/Avnet-S6LX9-MMU-tiny-13.1


# 5. ecos application development on i386 virtual machine

Befor port ecos operating system to the development board, application developers can develop applications in i386 virtual machine environment  come from ecos.

## 5.1 redboot

### 5.1.1 COMPILE redboot

In configtool,

- Set `Hardware` as

        i386 PC target (vmWare)

- Set `Packages` as

        redboot

- Increase the `Packages`:

        Common ethernet suppport

- Set `eCos HAL->i386 architecture->i386 PC Target->Startup type` as

        FLOPPY

If you do not want typing the following command every time after start redboot

    ip_address -h host_computer's_ip_address

to make `load` command download elf file from the tftp, you can set `Redboot ROM monitor->Build Redboot ROM ELF image->RedbootNetworking->Default IP address->Default bootp server` ip address of the host computer (note that ip address here separated by comma not dot).

Finally `File->Save As...` save as redboot_pc_vmWare.ecc then `Build->Library` can get redboot_pc_vmWare_install/bin/redboot.bin, then use the following command to convert it into an available virtual machine floppy image:

    dd if=/dev/zero of=redboot.img bs=512 count=2880
    dd if=redboot.bin of=redboot.img conv=notrunc

If you are in Windows, such as Cygwin, you can execute the following command:

    dd conv=sync if=redboot.bin of=redboot.img (or .flp type) bs=1440k

### 5.1.2 RUN redboot

In the virtual machine software such as VirtualBox, create a new virtual machine with Other operating system and Other version, create a new floppy disk controller at the media of the virtual machine's configuration, and then register the redboot.img generated above to become VirtualBox virtual floppy in the operation of creating new floppy.

Start the virtual machine and you can see the command-line interface of redboot. Enter the help command can get help of redboot.

## 5.2 COMPILE ecos the operating system

In configtool, set `Hardware` to `i386 PC target (vmWare)`, set `Packages` to `net`, save it as ecos_pc_vmWare.ecc and compile.

## 5.3 ecos application

### 5.3.1 COMPILE ecos application

Same with the aforementioned `3.3 COMPILE ecos application`.

### 5.3.2 RUN ecos application

In redboot, download elf file:

    load elf_file

In redboot, run elf file:

    go



# Appendix: Code management process to prepare for subsequent updates

- Use the following command to download tool which can convert hg repository into git repository:

        git clone https://github.com/offbytwo/git-hg.git

- Use the following command to download the ecos code:

        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/ecos
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/ecos-v2_0-branch
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/ecos-v3_0-branch
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/flash_v2
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/images
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/nand-ecoscentric
        ~/proj/git-hg/bin/git-hg clone http://hg-pub.ecoscentric.com/yaffs-ecoscentric-gpl

- Use the following command to download the code needed in the compiling of the ecos-tools:

        git clone https://github.com/wxWidgets/wxWidgets.git


- Use the following command to download the tool which can convert cvs repository into git repository:

        sudo apt-get install git-cvs

- Use the following command to download the ecos code, and finally found the code in the hg repository is more appropriate, so the following code is obsolete:

        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos ecos
        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos ecos/host
        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos ecos-opt
        git cvsimport -v -d :pserver:anoncvs@ecos.sourceware.org:/cvs/ecos htdocs

- Using the following command in ecos directory to convert the `3.0 release` version of some reference code into the `current` version, so that they can be cleanly put into the git repository to do the comparison:

        find . -name v3_0 -type d | xargs rename "s/v3_0/current/"
        find . -name *.ecm | xargs sed -i "s/v3_0/current/g"

- Using the following command in ecos directory to convert the `2.0 release` version of some reference code into the `current` version, so that they can be cleanly put into the git repository to do the comparison:

        find . -name v2_0 -type d | xargs rename "s/v2_0/current/"
        find packages/templates -name v2_0.ect -type f | xargs rename "s/v2_0/current/"
        find packages/templates -name *.ect | xargs sed -i "s/v2_0/current/g"
        find packages -name *.ecm | xargs sed -i "s/v2_0/current/g"

- Using the following command in ecos directory to remove the file permissions of the reference code, so that they can be cleanly put into the git repository to do the comparison:

        git diff --summary | grep --color 'mode change 100755 => 100644' | cut -d' ' -f7- | xargs -d'\n' chmod +x
        git diff --summary | grep --color 'mode change 100644 => 100755' | cut -d' ' -f7- | xargs -d'\n' chmod -x

- Use the following command to rename .cvsignore to .gitignore:

        find . -name ".cvsignore" | xargs rename "s/cvs/git/"
