Li Zheng flyskywhy@gmail.com

# 将 IPFS 公共网关用作免费云剪贴板
IPFS 上的数据可以通过如下两种协议进行存取：

* ipfs: 在本地（或象 Brave 浏览器那样内部自动）启动一个 `ipfs daemon` 并使用 ipfs 协议从自己本地 `127.0.0.1` 地址存取
* https: 一些机构或个人在公网上用其服务器启动 `ipfs daemon` 并开放 ipfs 的 gateway 功能，他人即可从远程 https 地址存取

只要某个运行着 `ipfs daemon` 的已联网设备（也称 peer 节点）的 ipfs 仓库中含有某文件，且联网时间足够长（通过 `ipfs swarm peers` 命令可以看到连接着许多节点），他人即可通过上述两种方式之一读取该文件。

[Ipfs public gateway status](https://ipfs.fooock.com/) 上列出了许多 IPFS 公共网关，大部分是只读的，有一小部分还可以写入数据。只要有人通过某网关读写过数据，该数据就同样也会被保存在该网关节点的 ipfs 仓库中， ipfs 仓库的容量是有限的，当超限时 `ipfs repo gc` 会被触发，那些没有曾经被网站通过 `ipfs pin` 长久保存的文件就会被清理掉。因此按照是否被网站 `ipfs pin` 过，可以写入数据的网关可分为两类：

* 长存，通过登录其网站付费上传文件，同时网站会帮你运行 `ipfs pin` 命令
* 短存，公开了写入功能即任何人可以免费 POST 上传数据，在不知何时 `ipfs repo gc` 前，该数据一直可用

因此短存网关可以作为一个临时免费云剪贴板使用。

## 保存数据
以 curl 为例，使用如下命令进行 POST ：

    curl -d "sl2c0001" https://ipfs.eternum.io/ipfs/ --verbose

如果在该命令的输出打印中发现存在 `ipfs-hash` 字段，比如

    < ipfs-hash: QmZJsREMP5j6dbRhVVczegaN7cTDi44Bfk48nH1pznLqto

则说明 POST 成功

## 读取数据
以 curl 为例，使用如下命令进行 GET ：

    curl https://ipfs.eternum.io/ipfs/QmZJsREMP5j6dbRhVVczegaN7cTDi44Bfk48nH1pznLqto

这里的那堆“乱码”就是来自于上面 `ipfs-hash` 的值，这个命令会输出之前 POST 上传上去的 `sl2c0001`

2019 年 3 月国内如下网址皆可读写

    https://ipfs.sopinka.com/ipfs/
    https://pactcare.online/ipfs/
    https://ipfs.eternum.io/ipfs/
    https://ipns.co/ipfs/
    https://hardbin.com/ipfs/
    https://ipfs.jes.xxx/ipfs/
    https://siderus.io/ipfs/

2021 年国内只剩下 `ipfs.eternum.io` 可用，如想要更多，只能按 [Ipfs public gateway status](https://ipfs.fooock.com/) 中的列表一个个去测试了，期待有人写个自动测试脚本。
