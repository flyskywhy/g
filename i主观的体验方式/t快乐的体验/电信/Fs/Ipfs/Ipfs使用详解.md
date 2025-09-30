Li Zheng flyskywhy@gmail.com

# IPFS 使用详解

# 本地/服务器运行 go 语言版本 IPFS 节点
## 安装
翻墙后，在 [IPFS 官网](https://ipfs.io) 点击 “Try it” 按照提示下载，解压后按照其中的 README.md 进行安装并首次运行 `ipfs init` 来初始化 `~/.ipfs/` 。

类似 git 仓库的 `.git/` 目录在 git 软件中所起的作用，用于 ipfs 软件的 `~/.ipfs/` 目录存储着当使用 `ipfs cat` 等命令获取别人添加到 ipfs 网络中的文件时自动从网上下载的数据或是使用 `ipfs add` 等命令将本地文件添加到 ipfs 网络时所转换成的数据。该目录默认存储空间为 10GB ，可以通过 `./ipfs/config` 文件中的 `Datastore.StorageMax` 进行修改。或者如果不想使用默认的 `~/.ipfs` ，则在运行 `ipfs init` 等命令前设置一个环境变量 `IPFS_PATH` 。

根据 `ipfs init` 运行后出现的提示运行 `ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme` ，我们就可以查看 readme 文件的内容。该文件也可以通过浏览器访问 `https://ipfs.io/ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme` 来查看，还可以通过本地运行 `ipfs daemon` 启动网关 `/ip4/127.0.0.1/tcp/8080` 后用 `http://localhost:8080/ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme` 来查看。

`ipfs daemon` 除了启动网关，它还提供了一个浏览器图形界面 `http://127.0.0.1:5001/webui` 。

## 运行
启动节点： `ipfs daemon`

关闭节点： `ipfs shutdown`

在 Ubuntu 中使用 `ipfs daemon` 或者 `nohup ipfs daemon &` 命令，在关闭 xshell 的时候， ipfs 都会自动停止运行。如果期望稳定运行，可以根据[https://discuss.ipfs.io/t/ipfs-running-bug/782/9](https://discuss.ipfs.io/t/ipfs-running-bug/782/9)描述的内容，需要把 ipfs 创建为一个 systemd 服务。

### 创建 `ipfs.service` 文件
    sudo vim /lib/systemd/system/ipfs.service

内容如下：
```
[Unit]
Description=IPFS daemon
After=network.target
[Service]
ExecStart=/usr/local/bin/ipfs daemon
Restart=always
User=*put your own user here*
Group=*put your own group here*
[Install]
WantedBy=multi-user.target
```
设置开机启动

    sudo systemctl enable ipfs.service

开启 ipfs 服务

    sudo systemctl start ipfs.service

停止服务

    sudo systemctl stop ipfs.service

# 本地/应用运行 js 语言版本 IPFS 节点
## nodejs 中运行
全局安装 `npm install ipfs -g` 。

浏览器图形界面 `http://127.0.0.1:5002/webui` 。

## 浏览器中运行
本地安装 `npm install ipfs`

# 在应用间分享数据时提升连接 IPFS 网络的速度
同一种应用在不同手机间通过 IPFS 网络来分享数据时，由于一般只在应用启动时才启动应用内 ipfs 实例，所以如果不加特殊处理，花在两台手机间建立 `ipfs swarm peers` 连接的时间会很长，用户体验较差。

经使用 go-ipfs 在两台局域网电脑上几个小时的反复测试 ipfs 的 daemon 、 add 、 cat 、 shutdown 命令，发现如下现象：

* 使用默认的 `./ipfs/config` 文件时， cat 一个新 add 的文件需要 4 分钟以上；
* 将 `./ipfs/config` 文件中 bootstrap 只保留一个可用地址时（那些 ping 不通的 bootstrap.libp2p.io 地址倒是留在那里也没关系）， cat 一个新 add 的文件需要 1 分钟；
* 在上面的 `./ipfs/config` 文件基础上，在 bootstrap 里增加或只保留 "/ip4/对方电脑的 IP 地址/tcp/4001/p2p/对方电脑的 PeerID" ， cat 一个新 add 的文件只需要 1 秒钟；
* 如果在默认的 `./ipfs/config` 文件中增加或只保留 "/ip4/对方电脑的 IP 地址/tcp/4001/p2p/对方电脑的 PeerID" ， cat 一个新 add 的文件仍然需要 4 分钟以上。

这里提到的 PeerID 指的是 `./ipfs/config` 中的 `Identity.PeerID` 。

可以试验运行较久 ipfs daemon 的电脑上用 `ipfs swarm peers --verbose` 得到的节点 peer 列表，配合 `http://127.0.0.1:5001/webui` 中的 Peers 中的国家城市信息，找到合适（延时最小？位置最近？ `/libp2p/circuit/relay/` 数量最多的？）自己电脑所在位置的一些中继 relay 节点。

对于两个都位于 NAT 后内网的节点来说，比较合适方法是：

1. 在各自的 `~/.ipfs/config` 的 Bootstrap 中添加合适的拥有 `/libp2p/circuit/relay/` 的节点比如：

    `/ip4/xx.xx.xx.xx/tcp/4001/p2p/QmASDF1asDf2ASDfghjkAs3A4sd5FAsDfAsdfaS67ASdFg`

    当然，这也可以如步骤 4 中一样用 `ipfs swarm connect` 来添加。

2. 在各自节点中运行

    `ipfs daemon`

3. 过几秒钟后，在各自节点中运行如下命令确认都已连接上 QmASDF1asDf2ASDfghjkAs3A4sd5FAsDfAsdfaS67ASdFg

    `ipfs swarm peers | grep QmASDF1asDf2ASDfghjkAs3A4sd5FAsDfAsdfaS67ASdFg`

4. 在节点 A 中运行

    `ipfs swarm connect /p2p/QmASDF1asDf2ASDfghjkAs3A4sd5FAsDfAsdfaS67ASdFg/p2p-circuit/p2p/节点 B 的 PeerID`

    此时如果在前面步骤 2 中已经确认都连接上 QmASDF1asDf2ASDfghjkAs3A4sd5FAsDfAsdfaS67ASdFg 的话，就会出现如下提示：

    `connect 节点 B 的 PeerID success`

    否则：

    `Error: connect 节点 B 的 PeerID failure: dial attempt failed: <peer.ID Qm*节点A> --> <peer.ID Qm*节点B> dial attempt failed: error opening relay circuit: HOP_NO_CONN_TO_DST (260)`

    注：这是手动指定中继 relay 节点的方式，如果是[Understanding IPFS Circuit Relay](https://blog.aira.life/understanding-ipfs-circuit-relay-ccc7d2a39)中所说自动选择中继 relay 节点的方式，则只要 `ipfs swarm connect /p2p-circuit/p2p/节点 B 的 PeerID` 即可即可在 10 秒左右进行连接，但实际使用发现自动方式在默认 5 秒时间内极有可能连接失败，除非节点 B 的 `ipfs daemon` 已经启动足够长时间了（十分钟左右），所以还是手动方式更靠谱一些，而可以把自动方式作为最后的备选。按照 ipfs 官方的说法，自动方式只是某个 ipfs 版本试验用的，最新版已不支持。

5. 现在你会发现，在节点 A 中 `ipfs add` 一个文件的话，在节点 B 中 `ipfs cat` 出来只需要 1 秒钟左右。而且此时节点 A 或 B 中运行如下命令都会发现对方的身影

    `ipfs swarm peers | grep 对方节点的 PeerID`

6. 小结一下，这里只是用某个公共节点优化了 ipfs 默认保存着公共节点列表的 Bootstrap ，然后为了将节点 A 和 节点 B 首次找到对方的时间从 4 分钟左右减少为几秒钟，在某个节点中精确连接了对方节点的 PeerID ，而如果想要看到某个节点中某文件的变化，是需要将该节点 PeerID 作为 ipns 来访问那些一旦文件内容变化其哈希值就会变化的文件，也就是说这个 PeerID 类似于微信号一样，本来就是要告诉对方的，所以这仍然是一个分布式网络。还可以使用 `ipfs key gen` 命令生成新的公钥以替代 PeerID 用于 ipns ，参见[IPNS从入门到精通](http://www.songjiayang.com/posts/ipfsming-ming-xi-tong-shen-ru-jie-xi)。

7. 步骤 6 中说到 4 分钟也能找到的前提是把 `./ipfs/config` 文件的 `Swarm.EnableAutoRelay` 开启为了 true ，当然如果我们按照上面的步骤用 `swarm connect` 手动进行了 relay ，则 EnableAutoRelay 开不开启是无所谓的。另外，既然有心做 IPFS 相关的项目，为 IPFS 网络多贡献一台有公网 IP 的服务器也不为过吧？把服务器上的 `./ipfs/config` 文件的 `Swarm.EnableAutoNATService` 设置为 true 的话，就能让此服务器服务于那些开启了 EnableAutoRelay 的客户端了。

8. 如果节点 B 后来断过线再重连，就算节点 B 又再做过步骤 1 ，但之前步骤 4 中由节点 A 建立的连接并不会自动恢复。因此需要让节点 A 定时重复步骤 4 ，定时可以由调用 ipfs 的应用程序实现，也可以参考[How to Keep Your IPFS Nodes Connected to Ensure Fast Content Discovery](https://medium.com/pinata/how-to-keep-your-ipfs-nodes-connected-and-ensure-fast-content-discovery-7d92fb23da46)（无需翻墙的中文版本为[IPFS 教程：如何保持 IPFS 节点连接，确保快速发现内容？](https://www.chainnews.com/articles/622784390219.htm)）用 Linux 自带的定时功能实现。

9. 在使用 `ipfs name publish` 发布时默认需要 1 分钟时间，[IPNS very slow · Issue #3860 · ipfs_go-ipfs](https://github.com/ipfs/go-ipfs/issues/3860#issuecomment-386103425)测得所有的发布都需要这个时间，并在后续提到只要加上比如 `--timeout=2s` 参数就可以只需要 2 秒钟来发布，另外，在[DHT Query Performance · Issue #88 · libp2p_go-libp2p-kad-dht](https://github.com/libp2p/go-libp2p-kad-dht/issues/88#issuecomment-366808980)中解释了这 1 分钟的缘由。由于之前步骤 4 使用 `swarm connect` 进行了明确的连接，因此一般花 2 秒钟向当前连接的所有节点发布就足够了。然后浏览器打开 `http://127.0.0.1:8080/ipns/所需解析的PeerID/` 或者是命令行 `ipfs name resolve 所需解析的PeerID` 需要 30 秒钟，这是因为 IPNS 不象 IPFS 那样是 content-addressed ，而是每次都会随着 `ipfs name publish` 而改变的，所以 ipfs 需要等待搜集足够节点发来的 IPNS 信息来然后挑出最新的列出来。如果实在心急的，可以给 `ipfs name resolve` 加上 `--stream` 参数来即时一个个列出搜集来的 IPNS 信息而不是等到 30 秒后才列出一个，在之前步骤 4 的基础上在这里实测，解析出来的最短时间为 `4~10` 秒。

    结论：在最坏的情况（两个节点都位于 NAT 后面的内网），使用 IPNS 方式获得对方节点最新发布的较小的比如 JSON 文件内容最多需要 15 秒。
