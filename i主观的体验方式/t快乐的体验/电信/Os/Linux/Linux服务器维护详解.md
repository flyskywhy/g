Li Zheng <flyskywhy@gmail.com>

# Linux 服务器维护详解

## webmin
使用 webmin ，就可以在网页中以图形方式方便地管理 Linux 的各种配置文件，省去了命令行的繁琐。

常用的是“系统 | 用户与群组”，当然如果安装该 webmin 的 Linux 使用的是另外的 NIS 服务器的登录方式，则此处没有用处。

比较有用的是“系统 | Cron 任务调度”，比如添加这样的任务：

    sh /usr/cpulimit/cpulimit.sh >>/tmp/cpulimit/cpulimit.txt

这里的 `cpulimit.sh` 的内容如下：

    #!/bin/sh
    /usr/cpulimit/cpulimit2-alpha1/cpulimit2 -p `top -bn1 | awk '/CPU/,/abcdefg/ {if($9>89) print $1}'` -l 80 -z &

这样就可以把一过性的命令变成时刻运行的 daemon 。

## NIS
将一台 Linux 作为 NIS 服务器，这样用户帐号管理只在其上完成，而无需到许多 Linux 客户机上重复管理帐号了。参见 [帳號控管： NIS 伺服器](http://linux.vbird.org/linux_server/0430nis.php) 。

注：因 nis 需要 rpc ，所以如果发现 `systemctl status rpcbind.socket -l` 中报出错误 `rpcbind.socket failed to listen on sockets: Address family not supported by protocol` ，则参见 [rpcbind fails to start with IPv6 disabled](https://access.redhat.com/solutions/2798411) 一文解决。

确保客户机的 `/etc/nsswitch.conf` 里有如下内容：

    passwd:     nis files
    shadow:     nis files
    group:      nis files

在 NIS 服务器上将新用户添加到本地 files

    useradd -s /bin/bash -m -G git -u 100077 -d /users/UT02/U077_lizheng lizheng
    passwd lizheng

然后在 NIS 服务器上将新用户添加到 nis

    cd /var/yp
    make

现在就可以用新的用户名和密码登录客户机了。

后续如果用 `vi /etc/group` 命令修改了用户所属的组、用 `userdel` 命令删除了用户，都需要再 `make` 一下。

如果是修改用户密码的，则只需要用户自己用 `yppasswd` 命令即可，无需`make` 。

如果是修改用户的 Shell ，则需要用户使用如下命令，且后续同样无需 `make` ：

    ssh linuxNis
    chsh -s /bin/bash
    exit
    ypchsh

这里的 linuxNis 实际上是客户机的 `/etc/hosts` 文件中指明的 linuxNis 的 IP 地址，之所以要先登录到 linuxNis 进行一些处理是因为客户机的 `/etc/yp.conf` 中的 `domain silanrd.com server linuxNis` 语句指明了 linuxNis 就是 NIS 服务器。

## redhat 图形界面安装

    yum install xorg-x11-xauth xterm xorg-x11-fonts* google-noto-sans-simplified-chinese-fonts

并确保 `/etc/ssh/sshd_config` 里面有这一行:

    X11Forwarding yes

## 32 位库的安装
如果运行软件时碰到找不到 `/lib/ld-linux.so.2` 的错误，则：

    yum install glibc.i686

## [旧的 CentOS 安装新软件的方法](./旧的CentOS安装新软件的方法.md)
