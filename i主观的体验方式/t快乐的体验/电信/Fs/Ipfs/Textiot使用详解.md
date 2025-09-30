Li Zheng flyskywhy@gmail.com

# Textiot 使用详解

[textiot](https://github.com/flyskywhy/textiot) 是基于 [go-textile](https://github.com/textileio/go-textile) 等多个仓库整合成的单独仓库 A framework for building web and native (IoT) Dapps on the IPFS network

虽然本文所述 Thread v1 方法已被 Textile 官方废弃，但由于 Textile 官方新设计的 Thread v2 方法会使用 [email.textile.io](https://github.com/textileio/textile/blob/fb82b7b084e55b3939a8fdd1c3d7952a457433b5/cmd/textiled/main.go#L102) 这种中心化的域名寻址方式，不符合 IPFS 宣扬的分布式的内容寻址方式，可以判断 textiot 继续沿用的 Thread v1 方法更适合包括物联网领域的真正去中心化的使用。

## 安装开发环境
### 安装 go
为避免后续 `make setup` 过程中出现如下错误

    ERROR: Error: package 'textile-go' requires at least go version 1.13.

需到 [Downloads - The Go Programming Language](https://golang.org/dl/) （需翻墙）或 [Go语言中文网](https://studygolang.com/dl) 下载安装大于 1.13 版本的 go 语言环境（Ubuntu 21.10 `apt install golang` 出来的是 1.13 版本），并在 `~/.bashrc` 中配置好路径：

    export PATH=~/tools/go1.16.3/bin:~/go/bin:$PATH

## 安装 gomobile
如果要编译 Android 和 iOS 版本的 textile 库文件的，则还需

    go get golang.org/x/mobile/cmd/gomobile

如果这里 `go get` 会出现类似 `unrecognized import path "golang.org/x/mobile/cmd/gomobile` 的错误，则先做好下面“免翻墙管理 `~go/src/` 的方法”中的准备工作，然后：

    cd ~/go/src/github.com/golang
    git clone https://github.com/golang/mobile
    git clone https://github.com/golang/tools
    gomobile init

注意，如果升级了 go 的版本，这里的 `gomobile init` 需要被重新执行一次。

再从 [NDK 下载  _  Android NDK  _  Android Developers](https://developer.android.google.cn/ndk/downloads/index.html) 下载 ndk 并解压，然后

    export ANDROID_NDK_HOME=~/tools/android-ndk-r20

就可以正常使用 gomobile 了。

### 免翻墙管理 `~go/src/` 的方法
在 go 1.11 之前，或者 GO111MODULE 这个环境变量被设为 off 时，编译时所依赖的第三方组件位于 `~go/src/` ，这些组件的管理方式是 `go get` 。免翻墙准备工作如下：

    mkdir -p ~/go
    cd ~/go
    mkdir -p src/github.com/golang
    mkdir -p src/golang.org
    cd src/golang.org
    ln -s ../github.com/golang x

这样，当 go get 出现比如 `unrecognized import path "golang.org/x/mobile/cmd/gomobile"` 这样的错误时，就手动去下载 `golang.org/x` 在 github 上的镜像版本

    cd ~/go/src/github.com/golang
    git clone https://github.com/golang/mobile

然后再次执行之前出错的 `go get` 即可。

注：上面的 `~/go` 来自于 `go env` 命令输出的 GOPATH 。

### 免翻墙管理 `~go/pkg/mod/` 的方法
在 go 1.11 之后，或者 GO111MODULE 这个环境变量被设为 on 时，编译时所依赖的第三方组件位于 `~go/pkg/mod/` ，这些组件的管理方式是 `go mod` 。参考自 [解决 unrecognized import path "golang.org/x/sys"](https://www.cnblogs.com/sage-blog/p/10640947.html) 一文，此时的免翻墙方法非常简单：

    export GO111MODULE=on
    export GOPROXY=https://proxy.golang.com.cn,direct

### 安装 gcc-arm-linux-gnueabihf
如果要编译 ARM Linux 版本的 textile 的，则还需

    suod apt install gcc-arm-linux-gnueabihf

注意，如果不使用上面的 apt 安装的版本而是使用 linaro.org 的 arm-linux-gnueabihf ，则会导致 `collect2: fatal error: cannot find 'ld'` 的错误，参考 [cmd/link: fix ARM gold linker check](https://github.com/golang/go/commit/f2f3b6cd8fbe9f823fd6946f055bb70c3ef6f9db) ，主要是 linaro 的没有 golang 的 cgo 所需的 arm-linux-gnueabihf-ld.gold 而只有旧的链接器 arm-linux-gnueabihf-ld.bfd 的缘故。

## 安装 go-textile
### 获取源码及其所依赖的 go package
    git clone github.com/flyskywhy/textiot
    cd textiot/go-textile
    make setup

### 编译 x86 版本的 textile
    make textile

会生成 textile 可执行文件。

### 编译 ARM Linux 版本的 textile
    make textile-arm

会生成 textile-arm 可执行文件。

注： Makefile 中之所以额外加上 `-extldflags -static` 是为了避免可能的运行 textile 时出现的 `GLIBC_2.28 not found` 问题；将 `CGO_ENABLED=1` 改为 `CGO_ENABLED=0` 的做法实际上是不可行的，因为会导致运行时出现 `unknown driver "sqlite3"` 错误）。

如果后续运行 `textile-arm init` 或 `textile-arm daemon` 时出现如下错误

    sql: unknown driver "sqlite3" (forgotten import?)

则可能需要参考 [Link SQLite3 on ARM (x86_64 host)](https://stackoverflow.com/questions/47513189/link-sqlite3-on-arm-x86-64-host/47514836) ，在编译前先

    CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ CGO_ENABLED=1 GOOS=linux GOARCH=arm GOARM=7 go get github.com/mattn/go-sqlite3

### 在新版的 textiot 中自定义 react-native-sdk 后的编译方法只要一条命令

    ./build.sh

### 在旧版的 textile 中自定义 react-native-sdk 后的编译方法需要冗长的命令
为了能 [Update React Native APIs to match more closely the JS and Rest API](https://github.com/textileio/react-native-sdk/issues/108) ，有时需要自己添加一些 textile 还未添加的 API ，添加的流程是下面三个步骤。

#### 编译自定义 https://dl.bintray.com/textile/maven/io/textile/mobile/
##### 新版 gomobile 简单的操作方式
由于新版 gomobile 已支持 GO111MODULE ，因此编译步骤很简单。

先把 Makefile 里的 `android:` 中 `env go111module=off` 删除，然后

    go mod vendor
    make android

会生成 `mobile/dist/android/mobile.aar` 库文件。

##### 旧版 gomobile 复杂的操作方式
如果是某个不支持 GO111MODULE 的旧版 gomobile ，则编译步骤比较复杂。

此时如果不修改 Makefile ，直接在 go-textile 目录中

    make android

就会出现类似 `error writing go.mod: open /home/lizheng/go/pkg/mod/github.com/golang/protobuf@v1.3.1/go.mod445569628.tmp: permission denied` 这样的错误，这是由于不支持 GO111MODULE 的旧版 gomobile 没有把 `~go/pkg/mod/` 作为依赖进行编译，而只能依赖于 `~go/src/` ，解决方法是运行

    go mod vendor

这样就会自动将 `~go/pkg/mod/` 中的内容复制到 `go-textile/vendor/` 中，然后

    go get -d github.com/textileio/go-textile
    mv vendor ~/go/src/github.com/textileio/go-textile/

或是

    mkdir -p ~/go/src/github.com/textileio
    cd ~/go/src/github.com/textileio
    ln -s ~/proj/textile/go-textile go-textile

最后

    cd ~/go/src/github.com/textileio/go-textile/
    make android

会生成 `mobile/dist/android/mobile.aar` 库文件。

之所以没有直接在 `~/go/src/github.com/textileio/go-textile/` 中运行 `go mod vendor` 反而要折腾 mv 或是 ln ，是因为 `go: modules disabled inside GOPATH/src` 。

#### 编译自定义 https://dl.bintray.com/textile/maven/io/textile/textile/
这里以上面 go-textile 的版本是 0.7.1 来举例，如果是其它版本的，请自行修改。

    mkdir -p ~/maven/io/textile/mobile/0.7.1
    cd ~/maven/io/textile/mobile/0.7.1
    mv ~/go/src/github.com/textileio/go-textile/mobile/dist/android/mobile.aar ./mobile-0.7.1.aar
    curl -O https://dl.bintray.com/textile/maven/io/textile/mobile/0.7.1/mobile-0.7.1.pom

除了 mobile-0.7.1.aar 被 android-textile 所依赖外， pb-0.7.1.aar 也是，如果没有去自定义生成 pb-0.7.1.aar 的话，则直接用浏览器（无法用 curl）下载 https://dl.bintray.com/textile/maven/io/textile/pb/0.7.1/pb-0.7.1.aar 并存为 `~/maven/io/textile/pb/0.7.1/pb-0.7.1.aar` ， `pb-0.7.1.pom` 也照此办理。

获取 android-textile 源码

    cd ~/proj/textile
    git clone github.com/textileio/android-textile
    cd android-textile
    gitk --all

用 gitk 查看 git 历史并检出 `android-textile/manifest.gradle` 文件中 `textileVersion = '0.7.1'` 的版本比如 2.0.9 ，然后在 `android-textile/build.gradle` 中的 `allprojects.repositories` 中的最顶上添加 `maven { url "/home/lizheng/maven" }` ，最后获取 android-textile 所依赖的 java package 并编译

    ./gradlew androidDependencies
    ./gradlew textile:build

就会生成如下文件

    ./textile/build/outputs/aar/textile-release.aar
    ./textile/build/outputs/aar/textile-debug.aar

### 在 react-native-sdk 中使用自定义的 android-textile
这里以上面 android-textile 的版本是 2.0.9 来举例，如果是其它版本的，请自行修改。

    mkdir -p ~/maven/io/textile/textile/2.0.9
    cd ~/maven/io/textile/textile/2.0.9
    mv ~/proj/textile/android-textile/textile/build/outputs/aar/textile-release.aar ./textile-2.0.9.aar
    curl -O https://dl.bintray.com/textile/maven/io/textile/textile/2.0.9/textile-2.0.9.pom

注意检查这里的 textile-2.0.9.pom 中的 mobile 和 pb 版本的正确性，否则会产生编译正常但运行时 `java.lang.NoSuchMethodError: No virtual method` 等问题。

获取 react-native-sdk 源码

    cd ~/proj/textile
    git clone github.com/textileio/react-native-sdk
    cd react-native-sdk
    gitk --all

用 gitk 查看 git 历史并得知 `react-native-sdk/android/manifest.gradle` 文件中 `textileVersion = '2.0.9'` 的版本为 3.0.13 ，因此就在你自己的 APP 目录中

    npm install @textile/react-native-sdk@3.0.13

然后在你自己的 APP 目录中 `/android/build.gradle` 中的 `allprojects.repositories` 中的最顶上添加 `maven { url "/home/lizheng/maven" }` ，最后编译你自己的 APP 即可。

### 安装
在 `dist/` 中 `sudo ./install.sh` 即可将 textile 移动到 `/usr/local/bin/` 中。

## 运行 go-textile
### 初始化数字钱包 wallet
    textile wallet create
```
--------------------------------------------------------------------------------------
| 至      少      12      个      英      文      单      词     助     记     短     语 |
--------------------------------------------------------------------------------------
WARNING! Store these words above in a safe place!
WARNING! If you lose your words, you will lose access to data in all derived accounts!
WARNING! Anyone who has access to these words can access your wallet accounts!

Use: `wallet accounts` command to inspect more accounts.

--- ACCOUNT 0 ---
P帐号0公共地址4XeAmTWgTUBnp5imAvNmMsp6ppsq7jouJBMjXhC8
S帐号0私有种子12xVBcadT3a4xyiHrBvbrF5on6MeDwxrjUuFrwKF
```

上述命令可以反复运行多次，直到你觉得其输出的某个钱包助记短语 mnemonic phrase 足够让你容易记住，因为你可以将任何数字内容包括照片、文档等等通过这个数字钱包的某个帐号 ACCOUNT 加密保存在分布式文件系统 IPFS 中，这个助记短语就相当于钱包的钥匙，任何人只要得到这个助记短语，就可以得到钱包中的帐号来获取其中的内容，因此最好不要将助记短语保存在任何电子设备中，而如果你忘了这个助记短语也就丢失了所有的数据，因此助记短语最好是容易背诵的，或者干脆将助记短语写在某个实物上比如某张纸条上。

上面 `textile wallet create` 输出结果中虽然也列出了一个帐号，但实际上 `textile wallet create` 真的只是 create 了一个助记短语而已，只不过顺便列出了那个助记短语可以对应的许多许多（从后面 `textile wallet accounts` 命令的参数最大为 -d 100 -o100 来看，最多为 200 ）个帐号中的第 0 个也就是 ACCOUNT 0 ，其它的帐号可以通过命令显示出来，比如要查看从第 1 个开始查看共 2 个帐号的命令就是 `textile wallet accounts "至 少 12 个 英 文 单 词 助 记 短 语" -d 2 -o 1` 。之所以有这么多帐号，是为了方便用户用于各种应用程序或其它用途。

### 同步不同设备间的数据
同步数据或者叫自动备份，最现实的用途就是（如果不小心丢了笔记本，那）在新购笔记本电脑后只要在其上启动一个帐号 wallet 中的某个帐号就可以把该帐号中的数据同步过来了。

当然，前提是之前有至少另一台电脑运行着该帐号（该电脑会一直自动同步该账户中的数据），或者是该帐号之前在一台 textile Cafe 服务器上注册过（该服务器会一直自动同步一个或多个拿它的 token 注册过的帐号）。 textile Cafe 服务器需要自己按照[Cafe](https://github.com/flyskywhy/textiot/blob/master/docs/docs/concepts/cafes.md)一文创建。

### 安全
在任何一个设备上启动某个帐号（包括 `textile init` 初始化和 `textile daemon` 运行）帐号时都可以选择是否使用 `--pin` 参数，也就是 [Textile 桌面托盘软件](https://github.com/textileio/desktop) 登录时可选密码功能背后的操作，当使用该参数后，就算该设备上的 `~/.textile/` 被人复制出来了，他不知道该密码也无法运行帐号。

#### 修改密码
如果就是以上面提到的 --pin 来作为使用着 textile 功能的自己软件的登录密码，则修改密码时需要提醒用户只有已经将所有数据同步到 2 个或 2 个以上的设备或有注册过 textile Cafe 服务器上时，才能修改密码，因为我们目前应用层能做到的是将 `~/.textile/repo/` 自动删除再用新密码 `textile init` 重建出来，然后运行后花时间将数据同步过来。 textile 官方在最后的版本中没有提供修改密码功能，以后也不会了。

### 初始化一个帐号所对应的 textile IPFS peer 节点
帐号中以 S 开头的字符串就是私有种子。第一次为数字钱包初始化帐号时，请先使用 ACCOUNT 0 的私有种子，比如：

    textile init S帐号0私有种子12xVBcadT3a4xyiHrBvbrF5on6MeDwxrjUuFrwKF

这个操作会生成一个 `~/.textile/repo/` 目录，该目录中的结构与直接 `ipfs init` 出来的 `~/.ipfs/` 相同，只不过里面多了一个 `textile` 文件作为 textile-go 的配置文件。因此可以看出， textile 操作的就是 IPFS peer 节点，可以获得 IPFS 带来的各项好处，同时通过 textile-go 甚至再高一层的 [textiot](https://github.com/flyskywhy/textiot) 的 React Native APP 来更方便地处理 IPFS 上的数据。

### 启动一个帐号所对应的 textile IPFS peer 节点的服务进程
    textile daemon

这个服务进程启动后，就可以使用各种方式包括 textile 命令行来与这个节点互动了。

另外，该命令打印输出的第一行

    05 Mar 19 00:17 UTC  3WL12Gc added JOIN update to thread jXsWTvpd

的意思是在某个 UTC 时间，来自于 ipfs 的 `~/.textile/repo/config` 中的末 7 位为 3WL12Gc 的 Identity.PeerID 加入到了来自于 textile 的 `~/.textile/repo/textile` 中的末 8 位为 jXsWTvpd 的 Account.Thread 中。

## Thread
Textile 中 Thread 概念的意思是在某个帐号邀请其它帐号组成一个 Thread 或者更通俗一点的说法——群组后，组成员可以在 Thread 中记录数据的分享过程（类似于社交软件中的群聊），这样，这个 Thread 其实就充当了一个分布式数据库。

数据安全由 [Thread 的存取和分享类型](https://github.com/flyskywhy/textiot/blob/master/docs/docs/concepts/threads/index.md#access-control) 来控制：
```
Thread Type controls read (R), annotate (A), and write (W) access:

private   --> initiator: RAW, whitelist:
read-only --> initiator: RAW, whitelist: R
public    --> initiator: RAW, whitelist: RA
open      --> initiator: RAW, whitelist: RAW

Thread Sharing style controls if (Y/N) a thread can be shared:

not-shared  --> initiator: N, whitelist: N
invite-only --> initiator: Y, whitelist: N
shared      --> initiator: Y, whitelist: Y
```
"Writes" refer to messages and files, whereas "annotations" refer to comments and likes.

    textile threads add --type 'open' --sharing 'shared' --media "My Open+Shared+Media Thread"

该命令并不会在 `~/.textile/repo/textile` 文件中写入该新增 Thread 的信息，也就是说该命令打印输出的那些信息，有许多已经按照 [textile 区块链格式](https://github.com/flyskywhy/textiot/blob/master/docs/docs/concepts/threads/index.md#blocks) 被 `textile threads add` 写入了 ipfs 网络，还有一些信息则写在 `~/.textile/repo/datastore/` 本地数据库中。由于 Thread 信息中并未包含 Thread 的创建时间，同时本地数据库是按照 Thread 新建或同步时的入库顺序来将之保存的，则就算同一个帐号的不同节点上拥有相同的 Thread ，也可能这会导致 `textile threads ls` 输出的 Thread 顺序不同，所以如果你的业务项目依赖于这个顺序的话，可以在 `textile threads add` 时传入拥有时间规律的 key 。

该命令或是后续比如 `textile threads ls` 打印输出的 Thread 信息简介：

* id 就是 head.thread_id ，后续会被用于比如 `textile threads get` 作为输入参数
* key 只用于本地应用来辨别某个 Thread 而不在 ipfs 网络上传输，推测它可被用于在 peer 启动/恢复时快速找到 Thread ，因为多个 Thread 之间的 name 可以是相同的，可以直接用于 APP 显示比如分组名， APP 如果想按照一定字符串规律（比如上面提到的时间规律）快速定位一个 Thread 的话是需要一个别名的，而 id 是新建 Thread 时自动生成的， APP 无法控制其规律，所以 APP 可以选择在新建 Thread 时传入一个自定义的 key （命令行版本的 textile 如果不传入 key ，则会自动生成一个随机 key 返回）。
* head.author_id 就是 ipfs 的 `~/.textile/repo/config` 中的 `Identity.PeerID`
* initiator 就是 textile 的 `~/.textile/repo/textile` 中的 `Account.Address` 也就是 S帐号0私有种子 所对应的 P帐号0公共地址
* schema 指明了组成当前 Thread 中每个区块链的类型是 media 还是 json 等等，参见 [Default Schemas](https://github.com/flyskywhy/textiot/blob/master/docs/docs/concepts/threads/files.md#schemas) ，额外的， message 这个主要用于聊天的纯文本的区块链类型是不受 schema 限制的。

Thread 是由一堆区块链 block 组成的，`textile blocks ls -t 上面得到thread_id` 打印输出的那些 block 信息简介：
* id 后续会被用于比如 `textile likes ls -b` 作为输入参数

### 两个帐号在 Thread 中互动的示例
首先是用 `textile wallet init` 命令得到帐号1 。

如果是在另一台电脑上的话，简单重复上面的 `textile init` 和 `textile daemon` 即可。这里演示在同一台电脑中这两条命令所加的额外参数以及后续命令需要额外添加的 `--api` 参数。

    textile init S帐号1私有种子r1nJTadUQLqHmHzVBYe2wM73LTJWUh4fMtTEmoj5 -r .textile2/ -a 127.0.0.1:41600 -c 127.0.0.1:41601 -g 127.0.0.1:5150
    textile daemon --repo-dir=.textile2/

首先是帐号0 把帐号1 添加为联系人

    textile contacts add -a <P帐号1公共地址>

此时如果两个 textile 之间已经自动通过 IPFS 网络连接了的话（可以通过 `textile ping 帐号1的peers[0].id` ，就会出现如下提示：

    Add 1 contact? [y/n]: y

否则：

    No contacts were found

联系人添加好后，帐号0 再把帐号1 邀请进一个 Thread 中

    textile invites create -a <P帐号1公共地址> <thread-id>

此时如果之前帐号0 已经把帐号1 添加为联系人了的话，就会出现如下提示：

    {
        "id": "邀请id1CtzKgpPqkSiHZASEBYsSUHu2nSh3dYBjnGnHrJw45"
    }

否则：

    contact not found

正常的话，帐号1 的 daemon 会打印出

    11 Mar 19 16:13 CST   invited you to join zu3yjmV

另外，这个 `邀请id` 也可以用帐号1 运行如下命令获得：

    textile invites ls --api=http://127.0.0.1:41600
    {
        "items": [
            {
                "date": "2019-03-11T08:13:33.016950472Z",
                "id": "邀请id1CtzKgpPqkSiHZASEBYsSUHu2nSh3dYBjnGnHrJw45",
                "inviter": {
                    "address": "P帐号0公共地址4XeAmTWgTUBnp5imAvNmMsp6ppsq7jouJBMjXhC8"
                },
                "name": "My Open+Shared+Media Thread"
            }
        ]
    }

帐号1 接受该邀请加入该 Thread 中：

    textile invites accept <邀请id> --api=http://127.0.0.1:41600
    {
        "author": "12D3KooWRFH28AZrHyVB2jC9oswXMsdEd6mZBU5eYDUkBfEkhdQn",
        "date": "2019-03-11T08:17:55.355149476Z",
        "id": "QmTNtDmvq9vk3vGr1tkFxgbMccBGULXh6J5GBpxtS2cpLo",
        "parents": [
            "QmfJccwwfsKoNindNkHD7yptXQWumerjYt38oT4evNfdVg"
        ],
        "thread": "12D3KooWHocaCeNWExzXnxV8jmkLgofRjHMQjLDVEcfaczu3yjmV",
        "type": "JOIN",
        "user": {
            "address": "P帐号0公共地址4XeAmTWgTUBnp5imAvNmMsp6ppsq7jouJBMjXhC8",
            "name": "P帐号0"
        }
    }

此时帐号0 和帐号1 的 daemon 都会打印出一些 Thread 更新的信息，比如帐号0 会打印出：

    11 Mar 19 16:17 CST  P帐号0 added JOIN update to czu3yjmV
    11 Mar 19 16:17 CST  P帐号0 joined zu3yjmV

帐号1 会打印出：

    11 Mar 19 14:50 CST  P帐号1 added JOIN update to czu3yjmV
    11 Mar 19 16:17 CST  P帐号0 added JOIN update to czu3yjmV

而且在接受该邀请后，在帐号1 上才能用 `textile contacts ls --api=http://127.0.0.1:41600` 列出帐号0 。

在帐号0 上

    textile chat <thread-id>

在帐号1 上

    textile chat <thread-id> --api=http://127.0.0.1:41600

然后互相打字时， daemon 都会打印出一些 Thread 更新的信息，比如当帐号0 输入 `hello world` 后，帐号0 的 daemon 会打印出：

    11 Mar 19 16:26 CST  P帐号0 added TEXT update to czu3yjmV

帐号1 会打印出：

    11 Mar 19 16:26 CST  P帐号0 added TEXT update to czu3yjmV
    11 Mar 19 16:26 CST  P帐号0 hello world zu3yjmV

使用 `textile observe <thread-id>` 命令则会持续打印出该 Thread 更新的 block 内容

## 用于 IoT 项目时的技巧
### 一套产品的不同节点使用同一个 S帐号0私有种子
不论是 IoT ，还是用于控制的手机、平板，上面运行的基于 textiot 的命令行程序或 react native APP 作为节点，如果都使用同一个 S帐号0私有种子 来初始化的话，那么业务代码就可以设计成这些节点都只简单（无需 textile invites ）地从一个群组 Thread 中获取最新的 json 文件作为业务数据同步。而且，从商业角度来说，卖给一个客户的一套产品对应一个 S帐号0私有种子 （所对应的二维码），便于产品管理。

### 群组 Thread 中消息传送只用 pubsub 不用 chat 命令
Thread 底层是由区块链实现的，而区块链的优点——数据不可篡改，对于 IoT 设备来说就是缺点——数据无法删除以节省空间。所以为了避免存储空间较小的 IoT 设备长时间运行后由于空间不够而出故障，业务代码要尽量避免修改群组 Thread 。分布式存储使用的是 Thread 中保存的比如 json 文件，这个文件如果只用于保存配置信息，由于 IoT 配置完成后一般无需频繁修改，所以不是问题。分布式消息可以使用 ipfs 的 pubsub 功能也就是 textile ipfs pubsub pub 命令，而不使用会修改 Thread 的 textile chat 命令，这样也就没有问题。

## 参考链接
[docs](https://github.com/flyskywhy/textiot/tree/master/docs)

[tour of Textile](https://github.com/flyskywhy/textiot/tree/master/docs/docs/a-tour-of-textile.md)

[concepts](https://github.com/flyskywhy/textiot/tree/master/docs/docs/concepts)
