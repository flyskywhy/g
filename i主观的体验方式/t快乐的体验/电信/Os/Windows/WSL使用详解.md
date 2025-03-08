Li Zheng <flyskywhy@gmail.com>

在最新版的 Win10 的应用商店中安装好 Ubuntu 后，除了使用默认的命令行界面，还可以参考本文提供的方法使用图形界面、音频支持等功能。

## apt
首先

    sudo apt-get update

然后就可以安装软件比如 Geany 了

    sudo apt install geany

## 本地 X 窗口软件
安装并启动 [MobaXterm ](http://mobaxterm.mobatek.net) ，然后

    echo "export DISPLAY=***.***.***.***:0.0" >> ~/.bashrc

重启 Ubuntu 后，运行命令比如 `geany` 就能启动图形界面的 Geany 了。其中，***。***。***。*** 是wsl 的地址

## ssh 远程 X 窗口软件
直接使用 MobaXterm 自带的 ssh 会话就好。

## 音频支持
本节参考 [PulseAudio doesn't work](https://github.com/Microsoft/BashOnWindows/issues/486#issuecomment-235632914) 和 [wsl_gui_autoinstall.bat](https://github.com/aseering/wsl_gui_autoinstall/blob/master/wsl_gui_autoinstall.bat) 。
* Ubuntu 中安装音频驱动客户端
```
sudo add-apt-repository ppa:therealkenc/wsl-pulseaudio
sudo apt-get update
sudo apt-get install libpulse0 -y
echo export PULSE_SERVER=tcp:localhost >> ~/.bashrc
```
* Windows 中安装音频驱动服务端

将 [http://bosmans.ch/pulseaudio/pulseaudio-1.1.zip](http://bosmans.ch/pulseaudio/pulseaudio-1.1.zip) 下载解压到 `%AppData%\Roaming\PulseAudio` 中，然后在 `PulseAudio\etc\pulse\default.pa` 文件中添加一行：

    load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

新建 `%AppData%\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\start_pulseaudio.vbe` 文件，文件内容为：

    set ws=wscript.createobject("wscript.shell")
    ws.run "C:\Users\YOUR_NAME\AppData\Roaming\PulseAudio\bin\pulseaudio.exe --exit-idle-time=-1",0

记得替换这里的 YOUR_NAME 。

最后重启 Windows 和 Ubuntu 即可。

## 运行 32 位的 Linux 程序
[64 位的 Win10 只支持 64 位而不支持 32 位的 Linux 二进制可执行文件](https://wpdev.uservoice.com/forums/266908-command-prompt-console-bash-on-ubuntu-on-windo/suggestions/13377507-please-add-32-bit-elf-support-to-the-kernel) ，解决方法参见 [React使用详解](../../Tool/编程语言/JavaScript/React使用详解.md) 中 aapt 的例子。

## Windows 防火墙
由于 Windows 的防火墙无法自动在 WSL 中的 Linux 开启端口时弹出对话框让用户选择是否允许，所以在 Ubuntu 中开启的服务，只有 Ubuntu 或 Win10 本机才能访问该服务的端口，其它主机也来访问的方法参见 [React使用详解](../../Tool/编程语言/JavaScript/React使用详解.md) 中 packager server 的例子。

## 腾讯 WeGame 导致无法监听端口
如果安装了腾讯 WeGame 且发现 Ubuntu 中服务的监听端口（就算在本机也）不起作用，则按照 [这位自称 WeGame 开发团队人员所说](https://github.com/Microsoft/WSL/issues/1554#issuecomment-356542961) ，需做如下操作：

    下载安装最新版 [wegame](https://wegame.com)
    在 wegame 的安装目录比如 `C:\Program Files\WeGame` 中新建一个空文件 `UseNewDriver.cfg`
    删除 `system32/drivers/QMTgpNetFlow764.sys` 并重启电脑

## 中文字体支持
虽然默认的命令行界面用比如 `ls` 命令可以看到中文，但是在图形软件比如 gitk 中只能看到方块，此时就需要安装中文字体：

    sudo apt install ttf-wqy-zenhei ttf-wqy-microhei wkhtmltopdf

## 文件编辑
虽然在 Ubuntu 开启的时候，用 Windows 中的文本编辑器可以直接编辑 Ubuntu 中的文件比如 `C:\Users\YOUR_NAME\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_77rhkp7fndgsc\LocalState\rootfs\home\YOUR_NAME\.bashrc` ，文件的 Linux 权限也不会被改变，但是当 Ubuntu 重启后就会发现，该文件的 Linux 权限已经变成了 000 ，所以更合适的方式是使用 Ubuntu 中的文本编辑器比如占用资源较小的 geany 或是更全能的 [Sublime Text](../../Tool/文档编辑/SublimeText/SublimeText使用详解.md) 。
