Li Zheng <flyskywhy@gmail.com>

# VPN 路由设置详解
设置路由的意思是，设置是否把拨 VPN 后所获取来的网关比如 100.100.100.1 作为自己访问因特网上所有 IP 地址的网关（也就是默认网关）或仅仅是某一类或某一个 IP 地址的网关。

## 通过 VPN 连接发送所有流量——设置所有 IP 地址的路由
* Windows 上在 `控制面板 | 网络连接 | 右键属性` 或是 Win10 的 `设置 | VPN | 更改适配器选项 | 右键属性` 的 `网络 | Internet 协议 | 高级 | 常规 | 在远程网络上使用默认网关` 打上勾（默认为勾上）
* macOS 上在 VPN 拨号设置中的 `高级 | 选项 | 会话选项 | 通过VPN连接发送所有流量` 打上勾（默认为不勾上）
* Linux 上在 VPN 拨号设置中的 `IPv4 | 仅对该网络上的资源使用此连接` 不打上勾（默认为勾上）

注，如果不是使用 Windows 自带的 VPN ，而是使用名为 GlobalProtect 的 VPN 软件，则不存在 `在远程网络上使用默认网关` 打勾选项，而只存在路由设置选项。

## 图形界面设置某一类或某一个 IP 地址的路由

### Linux Ubuntu
在 VPN 拨号设置中的 `IPv4 | 路由` 中可以看到
```
地址: 10.19.49.0
子网掩码: 255.255.255.0
网关: 100.100.100.1
跃点: 0
```
如上设置的意思是说，如果本机想要访问地址范围为 `10.19.49.0~10.19.49.255` 的网络主机，则需要以 `100.100.100.1` 为网关、跳跃距离为 `0` 来访问，否则就以默认的网关（比如本地网络自动获取来的 `192.168.1.1` ）来访问。

可以使用 `mtr` 命令来查看网关跳跃的路径，例如这个命令： `mtr 公网.xx.xx.91`

上面是设置某一类 IP 地址的路由，下面是设置某一个 IP 地址的路由
```
地址: 公网.xx.xx.91
子网掩码: 255.255.255.255
网关: 100.100.100.1
```

## 命令行界面设置某一类或某一个 IP 地址的路由
## Linux

设置某一类 IP 地址 `10.19.49.0~10.19.49.255` 的路由

    sudo route add -net 10.19.49.0 netmask 255.255.255.0 gw 100.100.100.1 dev ppp0

删除路由

    sudo route del -net 10.19.49.0 netmask 255.255.255.0 gw 100.100.100.1 dev ppp0

设置某一个 IP 地址的路由

    sudo route add -net 公网.xx.xx.91 netmask 255.255.255.255 gw 100.100.100.1 dev ppp0

## Windows

用管理员身份运行如下命令，设置某一类 IP 地址 `10.19.49.0~10.19.49.255` 的路由

    route -p add 10.19.49.0 mask 255.255.255.0 100.100.100.19

设置某一个 IP 地址的路由

    route -p add 公网.xx.xx.91 mask 255.255.255.255 100.100.100.19

这里之所以是 `100.100.100.19` 而非 `100.100.100.1` ，可能是 Windows (XP) 的 BUG ，即在 VPN 连接后的属性中明明看到服务器地址是 `100.100.100.10` 和客户端地址是 `100.100.100.19` ，但设置路由时却要将客户端地址作为网关。

## macOS

查看路由

    netstat -nr

设置某一类 IP 地址 `10.19.49.0~10.19.49.255` 的路由

    sudo route add -net 10.19.49.0 -netmask 255.255.255.0 100.100.100.1

设置某一个 IP 地址的路由

    sudo route add -net 公网.xx.xx.91 -netmask 255.255.255.255 100.100.100.1

上面的命令等价于

    sudo route add -net 10.19.49.0/24 100.100.100.1
    sudo route add -net 公网.xx.xx.91/32 100.100.100.1

这里 24 代表的意思是子网掩码 `netmask 255.255.255.0` 也就是二进制 `11111111.11111111.11111111.00000000` 从左向右数共有 24 个 1

### macOS 上自动设置路由的脚本
因为 `*nix` 的 `route` 命令没有 `-p` 选项（设置为静态路由），重启后，设置的路由又无效了，必须重新运行命令，比较麻烦，所以写成脚本， 每次开机运行下，是一个方法。

macOS 中可以设置成启动项，每次开机自动运行，方法是：

* 在 `H:\Library\StartupItems\` 下新建一个目录，比如命名为 `SetRoutes`

* 在 `SetRoutes` 目录下新建一个文本文件（比如命名为 `SetRoute` ），写上脚本程序如下：

```
#!/bin/sh

# Set up static routing tables

. /etc/rc.common

StartService ()
{
        ConsoleMessage "Adding Static Routing Tables"
        route add -net 10.19.49.0/24   100.100.100.1
        route add -net 公网.xx.xx.91/32 100.100.100.1
}

StopService ()
{
        return 0
}

RestartService ()
{
        return 0
}

RunService "$1"
```

* 新建一个 `StartupParameters.plist` 文件，指定命令参数，内容如下:
```
{
        Description     = "Set static routing tables";
        Provides        = ("SetRoutes");
        Requires        = ("Network");
        OrderPreference = "None";
}
```

* 修复磁盘权限, `chmod 755 *` 重启

### macOS 上解决自动断开 VPN 的问题
有时会发现 macOS 长时间不操作的话，它会自动断开 VPN ，参考了 [Mac技巧之让苹果电脑 VPN 断开后自动重连的方法](http://www.mac52ipod.cn/post/get-vpn-to-auto-reconnect-on-mac-os-x-by-applescript.php) 和 [VpnInit AppleScript: Override and Restore Default VPN-Routes on OS ](http://phaq.phunsites.net/2011/12/29/vpninit-applescript-override-and-restore-default-vpn-routes-on-os-x/) ，得到了如下自动重连 VPN 及设置路由的脚本：
```
on idle
    tell application "System Events"
        tell current location of network preferences
            set myConnection to the service "Aliyun"
            if myConnection is not null then
                if current configuration of myConnection is not connected then
                    connect myConnection
                end if
                set counter to 0
                repeat while counter is less than 16
                    if current configuration of myConnection is connected then
                        do shell script "route add -net 公网.xx.xx.91/32 100.100.100.1" password "你的macOS登录密码" with administrator privileges
                        exit repeat
                    end if
                    set counter to counter + 1
                    delay 1
                end repeat
            end if
        end tell
        return 120
    end tell
end idle
```
