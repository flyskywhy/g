Li Zheng <flyskywhy@gmail.com>

# VPN 连接创建详解
也可参考 [Client VPN OS Configuration](https://documentation.meraki.com/MX-Z/Client_VPN/Client_VPN_OS_Configuration) 来创建连接。

VPN 可以连接成功后，一般需要进行 [VPN 路由设置](./VPN路由设置详解.md) 来更好地让 VPN 服务于自己的工作。

## 图形界面创建一个 VPN 的连接
### Linux Ubuntu
在 `设置 | 网络 | VPN | 添加 | PPTP | 身份` 中输入

* 网关: `公网.xx.xx.120`
* 用户名
* 密码
* 进入 “Advanced” ，勾选 MPPE

注，如果上面“添加”时的下拉菜单中没有 PPTP 选项，则需先 `sudo apt-get install network-manager-pptp-gnome` 。

连接失败解决方法汇总：

在 `Ubuntu 17.10` 上，打开 VPN 开关时会立即自动关闭，导致连接失败，在打开 VPN 开关时于 `tail -f /var/log/syslog` 中可以看到报错信息 `Invalid VPN service type (cannot find authentication binary)` ，经搜索发现，只要在配置 VPN 的对话框中密码旁边的下拉菜单中从 `Store the password only for this user` 改为 `Store the password for all users` 即可解决问题。

### Windows
通过 `网络和共享中心 | 设置新的连接和网络 | 连接到工作区 | 创建新的连接 | 使用我的 Internet 连接(VPN) | 协议为 PPTP 及地址为 公网.xx.xx.120` 来添加，然后输入：

* 用户名
* 密码

注，如果你当前正在添加 VPN 的 Windows 是远程登录的，则在拨 VPN 前记得不要设置为 [通过 VPN 连接发送所有流量](./VPN路由设置详解.md) ，否则远程登录就会断开，只能物理重启。

### macOS
* 打开系统偏好设置并转到网络部分
* 在窗口左下角单击 + 按钮
* 从 `接口` 下拉菜单选择 VPN
* 从 `VPN类型` 下拉菜单选择 `IPSec 上的 L2TP`
* 在 `服务名称` 字段中输入任意内容
* 单击 `创建`
* 在 `服务器地址` 字段中输入 VPN 服务器地址 `公网.xx.xx.120`
* 在 `帐户名称` 字段中输入用户名
* 单击 `鉴定设置` 按钮
* 在 `用户鉴定` 部分，选择 `密码` 单选按钮，然后输入 VPN 密码
* 在 `机器鉴定` 部分，选择 `共享的密钥` 单选按钮，然后输入密钥
* 单击 `好`
* 选中 `在菜单栏中显示 VPN 状态` 复选框
* 单击 `应用` 保存 VPN 连接信息

## 命令行界面创建一个 VPN 的连接
### Linux
安装工具

    sudo apt-get install pptp-linux

在 `/etc/ppp/peers/` 中生成 VPN 配置文件

    sudo pptpsetup --create AliyunLizheng --server 公网.xx.xx.120 --username lizheng --password "你的密码" --encrypt

需要注意的一个 pptpsetup 的 BUG 是，如果以前曾用比如 AliyunLizheng 进行过 create 了，则再次运行 create 时会覆盖保存着 username 的 `/etc/ppp/peers/AliyunLizheng` ，但不会覆盖保存着 password 的 `/etc/ppp/chap-secrets` ！这就容易导致出现用户名和密码不匹配的情况，所以请注意删除 `/etc/ppp/chap-secrets` 中不再需要的密码。

#### Linux 启动 VPN

    sudo pon AliyunLizheng

此时运行 ifconfig 就会看到多出了一个 ppp0 ，并得知网关地址比如 P-t-P:100.100.100.1 以便后续添加路由所用。

如果等个几秒钟后、试了三、四次 ifconfig 都没有看到 ppp0 ，并且 `sudo vim /var/log/syslog` 看到有 `EAP: peer reports authentication failure` 这样的错误提示，则需要

    sudo vim /etc/ppp/options

添加

    refuse-pap
    refuse-eap
    refuse-chap
    refuse-mschap
    require-mppe

#### Linux 停止 VPN

    sudo poff -a
