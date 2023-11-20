Li Zheng <flyskywhy@gmail.com>

# 手机 VPN 分享给电脑使用
有时 VPN 服务器管理人员只提供了手机连接而没有电脑连接的方法，则可使用本文弥补之。

## 准备本地局域网
将手机与电脑置于同一路由器的局域网内，或者设置手机为个人热点并让电脑连上。

## 手机拨 VPN
在手机上安装 VPN 软件比如国内的 UniConnect ，并按照 VPN 服务器管理人员提供的配置进行设置，然后拨入。

最好在手机系统设置中将 UniConnect 设置为允许后台活动。

## 手机启动代理
在手机上安装代理软件比如 [Android Proxy Server](https://apkpure.com/android-proxy-server/cn.adonet.proxyevery) ，并依据不同使用场景设置相应的远程目的地地址：

* 想让电脑浏览器使用 VPN 局域网中某台代理服务器来科学上网的，则设置为该代理服务器的局域网 IP 和端口号
* 想让电脑使用 ssh 来登录 VPN 局域网中某台 SSH 服务器的，则设置为该 SSH 服务器的局域网 IP 和端口号

然后启动 Android Proxy Server 界面上的`TCP中继`。

最好在手机系统设置中将 Android Proxy Server 设置为允许后台活动。

## 电脑设置代理到手机 IP 地址和端口
依据不同使用场景来使用在启动`TCP中继`后所显示的“本机IP”和端口 2333 ：

* 想让电脑浏览器使用 VPN 局域网中某台代理服务器来科学上网的，在浏览器的代理设置中填入“手机本机IP”和端口 2333
* 想让电脑使用 ssh 来登录 VPN 局域网中某台 SSH 服务器的，使用`ssh 手机本机IP -p 2333`命令来登录
