# 安装 OpenSSH

Li Zheng flyskywhy@gmail.com

## WinXP
参考[Windows上安装配置SSH教程（2）——在Windows XP和Windows 10上安装并配置OpenSSH for Windows - feipeng8848](https://www.cnblogs.com/feipeng8848/p/8568018.html)

下载安装[OpenSSH for Windows](https://sshwindows.sourceforge.net/)

在安装目录比如`C:\Program Files\OpenSSH`中运行

    cd bin
    mkgroup -l >> ..etcgroup
    mkpasswd -l >> ..etcpasswd
    md home
    md home\Administrator
    md home\Administrator\.ssh

运行（win+r）里输入 regedit ，打开注册表，找到`[HKEY_LOCAL_MACHINE\SOFTWARE\Cygnus Solutions\Cygwin\mounts v2\/home]`，修改

    native 的数据为 C:\Program Files\OpenSSH/home

配置 Windows 防火墙，使其允许 sshd 服务在端口 22 上侦听

在“控制面板 | 管理工具 | 服务”中确认启动`OpenSSH Server`

参考[关于no matching key exchange method found. Their offer_ diffie-hellman-group1-sha1的解决办法 - feipeng8848](https://www.cnblogs.com/feipeng8848/p/9523416.html)，此时客户端可以例如这样登录了

    ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 Administrator@192.168.1.9

如果想免密登录，则需要将客户端的比如`~/.ssh/id_rsa.pub`复制为 Windows 中的`home\Administrator\.ssh\authorized_keys`文件

## Win10
参考[win10 安装ssh并作为服务器使用](https://www.jianshu.com/p/04e64bfcc79b)

在开始菜单“设置 | 应用 | 应用和功能 | 可选功能 | 添加功能”中安装 OpenSSH 服务器。

在开始菜单“Windows 系统 | Windows 管理工具 | 服务”中确认启动`OpenSSH SSH Server`

此时客户端可以例如这样登录了

    ssh SomeUser@192.168.4.9

如果想免密登录，则在将客户端的比如`~/.ssh/id_rsa.pub`复制为 Windows 中的`C:\Users\SomeUser\.ssh\authorized_keys`文件之后，参考[多台WIN10之间的SSH免密登录](https://zhuanlan.zhihu.com/p/111812831)，修改`C:\ProgramData\ssh\sshd_config`（首次启动 sshd 后会生成该文件）：
```
确保以下 3 条没有被注释
PubkeyAuthentication yes
AuthorizedKeysFile  .ssh/authorized_keys
PasswordAuthentication no

确保以下 2 条有注释掉
#Match Group administrators
#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

## 其它
scp 在针对 WinXP 或 Win10 时不能使用`~`，比如

    scp somefile.txt 192.168.4.9:~/temp/

不会正常工作，而

    scp somefile.txt 192.168.4.9:temp/

可以
