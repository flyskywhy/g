Li Zheng flyskywhy@gmail.com

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

## 通过 VPN 访问阿里云 ECS 安全组保护下的私有 IP 地址
为方便描述，这里首先定义下 IP 前缀：

* 公网 IP 为比如 `公网.xx.xx.131`
* 阿里云私有 IP 为比如 `私网.xx.xx.156`
* 公司局域网环境 IP 为比如 `内网.xx.xx.106`

再定义下两种 VPN ：

* 公司 VPN 比如 `公网.xx.xx.139` 在拨入后能够访问公司局域网内众多内网 IP
* 阿里云 VPN 比如 `公网.xx.xx.120 私网.xx.xx.85` 在拨入后能够访问同一阿里云帐号下的众多私网 IP

最后定义下两种 ECS :

* ecsClash 是与阿里云 VPN 在同一阿里云帐号下的 `公网.xx.xx.131 私网.xx.xx.156`
* ecsWeb 是与阿里云 VPN 在不同阿里云帐号下的 `公网.xx.xx.91`

### 服务端设置
这里首先解决的常见问题是，为何可以 `ssh 公网.xx.xx.131` 或 `ssh 私网.xx.xx.156` 登录 ecsClash ，但在拨入阿里云 VPN 后却无法达成允许访问`私网.xx.xx.156` 而禁止访问 `公网.xx.xx.131` 的某个端口比如 7890 的目的，这个问题一般是由于之前为了方便使用 ssh 而将 ssh 的 22 端口的入方向在 ecsClash 安全组中授权给 `0.0.0.0` 也就是任意 IP 皆可访问而不论是否 VPN ，解决方法简单来说就是在安全组中将 7890 端口的入方向授权给阿里云 VPN 的 `私网.xx.xx.85` 。

下面再介绍如何在对 ecsClash 和 ecsWeb 的安全组入方向进行设置后，可以达到只有特定 IP 才能访问 ecsWeb 的 IP 比如 `公网.xx.xx.91` 及其所代表的域名的安全目的。

在公司局域网环境下，只要将访问 <https://www.ipaddress.com> 后得到 IP 地址设置进 ecsWeb 的安全组即可，因为公司出口的公网 IP 一般是固定的。

在其它环境比如在家里时，路由器的公网 IP 一般是非固定的，但此时即使拨入公司 VPN 在以下一些情形也不一定会奏效：

* 如果不在命令行通过 route 命令设置正确的路由
* 如果走公司局域网 `内网.xx.xx.106` 中的代理服务到 `公网.xx.xx.131` 中的 clash 服务（参见 [Clash 使用详解](../../Tool/翻墙/Clash使用详解.md)），则有些网站比如 <https://medium.com/> 会出现 `ERR_CONNECTION_RESET` 或 `ERR_SSL_PROTOCOL_ERROR` 的错误

解决思路是 `客户端` -> `内网.xx.xx.106:8118` -> 阿里云 VPN -> ecsClash 的 `私网.xx.xx.156:7890` -> 自动体现为该 ecsClash 的 `公网.xx.xx.131` 来访问某个公网 IP 比如 `公网.xx.xx.91`

解决过程如下：

1. 在 `公网.xx.xx.120 私网.xx.xx.85` 中安装 VPN 软件使之成为阿里云 VPN
2. 在 `内网.xx.xx.106` 中拨入阿里云 VPN ，并 [设置当前 IP 地址的路由](../../Net/Vpn/VPN路由设置详解.md)
3. 在 `内网.xx.xx.106` 中安装运行 privoxy 这个纯粹的代理软件，并将其配置文件中的监听设为 `listen-address 0.0.0.0:8118` 、转发设为 `forward / 私网.xx.xx.156:7890`
4. 在 `公网.xx.xx.131 私网.xx.xx.156` 中参考 [Clash 使用详解](../../Tool/翻墙/Clash使用详解.md) 安装运行 clash 并将其配置文件中的监听设为 `mixed-port: 7890` ，如果 `公网.xx.xx.91` 所对应的域名后缀不是 cn 也就是不符合配置文件中 rules 处的 `DOMAIN-SUFFIX,cn,DIRECT` ，则需要添加比如 `DOMAIN-SUFFIX,你的.域名.com,DIRECT`
5. 在 `公网.xx.xx.131 私网.xx.xx.156` 的安全组中允许 7890 端口入方向对 `私网.xx.xx.85` 的授权
6. 在 `公网.xx.xx.91` 的安全组中允许 443 或 80 端口入方向对 `公网.xx.xx.131` 的授权

注，第 2 步中，一般来说 `内网.xx.xx.106` 是远程登录的，所以在拨 VPN 前记得不要设置为 [通过 VPN 连接发送所有流量](../../Net/Vpn/VPN路由设置详解.md) ，否则远程登录就会断开，只能物理重启。

注，如果只是想使用 clash 服务，则上述第 6 步可以省略。

注，如果只是想访问 `公网.xx.xx.91` ，则还可以这样：第 4 步中也安装运行 privoxy 这个纯粹的代理软件，并将其配置文件中的监听设为 `listen-address 私网.xx.xx.156:7890` 、转发设为 `forward / .` 。

注，通过阿里云 VPN 后再去访问 `私网.xx.xx.156` 时所体现的来源 IP ，除了在阿里云控制台中查找到 `公网.xx.xx.120 私网.xx.xx.85` 这一配对外，还可以直观地通过 `ssh 私网.xx.xx.156` 登录后用 `who` 命令看到 `私网.xx.xx.85` 这一运行结果。

### 客户端使用
* 如果不拨入公司 VPN ，也不拨入阿里云 VPN ，而只是将 http 代理设为 `内网.xx.xx.106:8118` ，此时只能在公司局域网环境下使用 `公网.xx.xx.131 私网.xx.xx.156` 上的服务以及访问 `公网.xx.xx.91` 及其所代表的域名
* 如果拨入公司 VPN ，则将 http 代理设为 `内网.xx.xx.106:8118` ，此时能在任何环境下使用 `公网.xx.xx.131 私网.xx.xx.156` 上的服务以及访问 `公网.xx.xx.91` 及其所代表的域名
* 如果拨入阿里云 VPN ，则将 http 代理设为 `私网.xx.xx.156:7890` ，此时能在任何环境下使用 `公网.xx.xx.131 私网.xx.xx.156` 上的服务以及访问 `公网.xx.xx.91` 及其所代表的域名
* 即不拨入任何 VPN ，也不设置任何代理，则只适合一种情况——在公司局域网环境下访问 `公网.xx.xx.91` 及其所代表的域名

## 通过 VPN 访问阿里云 ECS 安全组保护下的公有 IP 地址
上节中如果只是为了访问 `公网.xx.xx.91` 及其所代表的域名，则通过两次代理进行访问的效率会有所降低，特别是无法 `ssh 公网.xx.xx.91` 也就是访问 `公网.xx.xx.91` 的 22 端口。

首先在 `公网.xx.xx.91` 的安全组中允许 22 端口入方向对 `公网.xx.xx.139` 和 `公网.xx.xx.120` 的授权。

通过观察 macOS 上 `cat /etc/resolve.conf` 和 `ping 域名` 的运行结果，发现

* 连接公司 VPN 时， `resolve.conf` 中是 `nameserver 内网.xx.xx.xx` ， `ping 域名` 能出现 `公网.xx.xx.91`
* 连接阿里云 VPN 时， `resolve.conf` 中是 `nameserver 公网.xx.xx.136` ， `ping 域名` 不能出现 `公网.xx.xx.91`

因此推测是阿里云中我们自己的 `公网.xx.xx.136` 没有安装 DNS 服务。

另外观察发现如果在拨 VPN 前没有设置为通过 VPN 连接发送所有流量，就无法 `ssh 公网.xx.xx.91` ，反之则可。

### 客户端使用
* 拨 VPN 前在 VPN 拨号设置中设置为 [通过 VPN 连接发送所有流量](../../Net/Vpn/VPN路由设置详解.md) ，或是拨 VPN 后通过 [命令行界面设置某一类或某一个 IP 地址的路由](../../Net/Vpn/VPN路由设置详解.md)
* 如果是阿里云 VPN ，则需在 VPN 拨号设置中添加 `114.114.114.114` 作为 DNS （在通过 VPN 连接发送所有流量这个设置的附近可以找到设置 DNS 的地方，另，貌似 Win10 开始无需设置 DNS）
