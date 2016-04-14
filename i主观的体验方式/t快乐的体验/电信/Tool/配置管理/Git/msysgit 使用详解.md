Li Zheng <flyskywhy@gmail.com>

# msysgit 使用详解
msysgit 是 git 的 Windows 版本。

## 下载安装
虽然 msysgit 已经被`Git for Windows`取代，但在`Git for Windows`还没有解决`git clone`时可能出现的`sssh-dss`错误之前，还是下载使用 msysgit 吧。

到 [https://github.com/msysgit/msysgit/releases](https://github.com/msysgit/msysgit/releases) 中，下载

    msysGit-fullinstall-某个版本.exe

然后运行安装。安装时在选则安装位置的地方直接写`D:\`，最后就会安装为`D:\msysgit\`，不要选择`D:\msysgit\`否则会安装为比较罗嗦的`D:\msysgit\msysgit\`。

## msys 终端窗口

运行安装目录中的`msys.bat`就可开启带有 git 和 mingw 编译环境的终端窗口，在这个终端窗口中可以运行各种 Linux 命令包括用 gcc 来编译 c 程序，当然我们的主要目的还是运行`git clone`命令下载 git 仓库或是用`git gui`和`gitk --all`命令打开图形界面。

## 换行符
安装好后要确保`msysgit/etc/gitconfig`文件中的`autocrlf = false`，否则如果为true的话可能会导致各种问题。

## 中文乱码
如果在 gitk 中发现文件内容里的中文变成乱码的，则需要在`msysgit/etc/gitconfig`中添加如下内容：

    [gui]
        encoding = utf-8
