Li Zheng <flyskywhy@gmail.com>

# 旧的 CentOS 安装新软件的方法
## 旧的 CentOS 6 切换 yum 源后自动安装
参照 [CentOS 6 EOL如何切换源？](https://help.aliyun.com/zh/ecs/user-guide/change-the-centos-6-source-address) ，在关闭上网通道的阿里云内网中的旧的 CentOS 6 的 yum 配置参见下文

专有网络 VPC 类型实例需切换为 `http://mirrors.cloud.aliyuncs.com/centos-vault/6.10/`

经典网络类型实例需切换为 `http://mirrors.aliyuncs.com/centos-vault/6.10/`

这里以专有网络 VPC 为例

    vim /etc/yum.repos.d/CentOS-Base.repo


```
[base]
name=CentOS-6.10
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/centos-vault/6.10/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.cloud.aliyuncs.com/centos-vault/RPM-GPG-KEY-CentOS-6

[updates]
name=CentOS-6.10
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/centos-vault/6.10/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.cloud.aliyuncs.com/centos-vault/RPM-GPG-KEY-CentOS-6

[extras]
name=CentOS-6.10
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/centos-vault/6.10/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.cloud.aliyuncs.com/centos-vault/RPM-GPG-KEY-CentOS-6
```

    vim /etc/yum.repos.d/epel.repo

```
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/epel-archive/6/$basearch
gpgcheck=0
gpgkey=http://mirrors.cloud.aliyuncs.com/epel-archive/RPM-GPG-KEY-EPEL-6
```

## 旧的 CentOS 6 手动下载 rpm 文件后进行手动安装
可以到 <https://rpmfind.net> 或 <https://vault.centos.org/6.0/os/x86_64/Packages/> 中下载

## 旧的 CentOS 5 运行 yum 报错 `No module named rpm`
CentOS 5 系统自带的 `/usr/bin/python` 原先是软链接到 `/usr/bin/python2.4` ，后来安装了 `2.7` 并使之软链接到了 `/usr/local/bin/python2.7` ，由于不存在 `/usr/local/lib/python2.7/site-packages/rpm` 目录所以报了 `No module named rpm` 的错

即使 `cp -a /usr/lib64/python2.4/site-packages/rpm/ /usr/local/lib/python2.7/site-packages/` ，运行 yum 仍会报错 `undefined symbol: Py_InitModule4`

可能解决方法只能是临时将软链接恢复到 `/usr/bin/python2.4`

## 旧的 CentOS 5 切换 PyPI 源后自动安装
参考 [Python 2.7中安装pip的方法及步骤](https://www.cjavapy.com/article/826/) 安装 pip

参考 <https://developer.aliyun.com/mirror/pypi> 在 `~/.pip/pip.conf` 中添加
```
[global]
index-url=http://mirrors.cloud.aliyuncs.com/pypi/simple/

[install]
trusted-host=mirrors.cloud.aliyuncs.com
```

## 旧的 CentOS 5 手动下载 rpm 文件后进行手动安装
可以到 <https://rpmfind.net> 或 <https://vault.centos.org/5.4/os/x86_64/CentOS/> 中下载

## 旧的 CentOS 7 手动下载 rpm 文件后进行手动安装
可以到 <https://rpmfind.net> 或 <http://mirrors.163.com/centos/> 或 <http://mirror.centos.org/centos/7/> 中下载
