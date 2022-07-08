Li Zheng <flyskywhy@gmail.com>

# Syncthing 在网络控制相关项目中的应用方式

[Syncthing](https://syncthing.net/)是一款开源网盘软件，它可以自动同步 Android 、 Linux 、Windows 上设置好的目录中的文件。利用这款软件，我们也可以让它简化网络控制相关项目中的网络代码，基本的思路是各个网络终端上的控制软件只读取本地文件系统中的文件进行操作，网络终端间的交互则由 Syncthing 来进行。

一般网络信息包的组成为包头和数据，而在我们使用 Syncthing 的情况下，包头可以简化成文件名当作命令，数据可以简化成文件内容当作命令的参数。

Syncthing 在同步文件过程中，会将被同步的文件加上前缀 `.syncthing.` 直到同步完成，基于这个特征，可以简化服务器软件（如果有的话）和终端软件的状态机设计。

实际应用可参考[Syncthing 在网络化测试机项目中的应用方式](Syncthing在网络化测试机项目中的应用方式.md)一文。

## Syncthing 多路终端的性能测试

实际生产环境下，会有许多终端存在，因此测试多个（比如1000个）终端经常性地与一个服务器同步时对性能的影响是很有必要的。

测试环境下，我们可以利用[Docker](https://www.docker.com/)技术，在一台 Ubuntu 电脑上开启许多个能够运行 Syncthing 的 Docker 容器模拟为终端，然后在另外一台服务器上测试性能。

### 安装 Docker Engine

Docker 的核心是 Docker Engine，其安装方式可以参考[Installation on Ubuntu](https://docs.docker.com/installation/ubuntulinux/#installation)，主要是如下安装命令：

    sudo curl -sSL https://get.docker.com/ | sh
    udo usermod -aG docker YOUR_UBUNTU_USER_NAME

然后测试一下是否运行正常：

    docker run hello-world

`docker run` 会自动从[Docker Hub](https://hub.docker.com)下载镜像到 `/var/lib/docker` 中然后运行。

### 测试多个 Syncthing 容器

测试用的是尺寸最小（小于30MB）的[开发者 gbrks 制作的 syncthing 镜像](https://hub.docker.com/r/gbrks/syncthing/)。

### 第 0 个测试容器

#### 建立配置目录和同步目录

在 Ubuntu 电脑上建立与容器内的 syncthing 的配置目录和同步目录映射的目录，以避免直接在容器内保存这两个目录的内容：

    sudo mkdir -p /pub/syncthing
    sudo chmod 2775 /pub/syncthing
    mkdir -p /pub/syncthing/0/config
    mkdir -p /pub/syncthing/0/sync

按开发者 gbrks 的说法，当前版本的镜像，需要把上面建立的两个目录的 UID 设置为1000。所以如果你在 Ubuntu 电脑上不是以1000的账户（安装 Ubuntu 时建立的第一个账户是1000的，可以用命令 `id` 来查看是否如此）登陆的，则需要运行如下命令：

    sudo chown -R 1000:1000  /pub/syncthing/0

#### 首次运行容器

运行如下命令，自动下载并启动：

    docker run -d \
      --restart=on-failure:20 \
      -v /pub/syncthing/0/config:/config \
      -v /pub/syncthing/0/sync:/sync \
      -p 8700:8384/tcp \
      -p 22700:22000/tcp \
      -p 21700:21025/udp \
      gbrks/syncthing:edge

#### 停止容器

运行如下命令：

    docker ps

将打印出来的 `CONTAINER ID` 哈希值用于如下命令：

    docker kill 哈希值

#### 修改配置后再次运行容器

此时配置目录 `/pub/syncthing/0/config` 中有文件产生了，使用文本编辑器将 `config/config.xml` 中的

    folder id="default" path="/home/syncthing/Sync"

修改为

    folder id="0" path="/sync"

然后重新运行前面的 `docker run` 命令。

#### 动态配置运行中的容器

对配置文件 `config/config.xml` 的修改，我们也可以通过网页的方式。

在服务器上用浏览器打开 Ubuntu 电脑的 IP 地址和上面 `docker run` 命令中的 8384 对应的端口号，比如 `http://192.168.19.49:8700/` ，就会看到该容器中正在运行的 syncthing 网页配置界面，下面简称终端配置界面。

在服务器上运行一个本地的[syncthing](https://github.com/syncthing/syncthing/releases)，它会自动用浏览器打开 URL 为 `http://127.0.0.1:8384/` 的 syncthing 网页配置界面，下面简称服务器配置界面。

在服务器上建立稍后会与终端同步的目录：

    mkdir -p /home/lizheng/Downloads/SyncTest/0

点击服务器配置界面中左下角的“添加文件夹”，在“文件夹标识”里填入 0 ，在“文件夹路径”里填入刚才建立的目录全路径。

点击终端配置界面中右上角的菜单中“显示设备标识”，复制哈希值标识，然后点击服务器配置界面中右下角的“添加设备”，在“设备标识”里填入刚才复制的哈希值，在“设备名”里填入 `DockerSync0` ，在“地址列表”里填入 `192.168.19.49:22700` （这里的22700就是和上面 `docker run` 命令中的 22000 对应的端口号，另外，如果服务器和终端所连接的网络都支持 UPNP 的，则这里的“地址列表”可以保持默认值 dynamic 不变），在“指定文件夹共享给设备”处选中 0 。这样过几秒钟后，你就会发现在终端配置界面中弹出一个“新设备”（其实就是服务器这个 Syncthing 设备）的提示信息，点击“添加”即可；接着又会弹出“共享文件夹”（其实就是刚才在服务器上操作的那个“添加文件夹”）的提示信息，点击“共享”即可。

### 第 1 个测试容器

#### 建立配置目录和同步目录

与上面的区别就是把 0 改为 1 。

    mkdir -p /pub/syncthing/1/config
    mkdir -p /pub/syncthing/1/sync

#### 运行容器

与上面的区别就是把 0 改为 1 、 8700 改为 8701 、 22700 改为 22701 、 21700 改为 21701 。

    docker run -d \
      --restart=on-failure:20 \
      -v /pub/syncthing/1/config:/config \
      -v /pub/syncthing/1/sync:/sync \
      -p 8701:8384/tcp \
      -p 22701:22000/tcp \
      -p 21701:21025/udp \
      gbrks/syncthing:edge

#### 停止容器

#### 修改配置后再次运行容器

与上面的区别就是把 0 改为 1 。

#### 动态配置运行中的容器

与上面的区别就是把 0 改为 1 、 8700 改为 8701 、 22700 改为 22701 。

### 自动测试脚本

为加快测试效率，编写了 `t.sh` 脚本，可以自动完成前述测试中的“建立配置目录和同步目录”、“运行容器”、“停止容器”、“修改配置后再次运行容器”这几个步骤，详见文末的“代码下载”中的“Syncthing 多路终端自动测试脚本”。

### 升级 Syncthing 镜像

每个容器都是由同一个镜像在运行时动态产生的，因此如果某个容器中的 syncthing （手动/自动）升级了，则可使用 `docker commit` 命令来生成一个新的镜像，这样下次各个容器启动时使用的就是最新的 syncthing 而不需要在各个容器中分别升级了。各个容器分别升级也是允许的，只不过是多占一点 `/var/lib/docker/aufs/diff` 中的磁盘空间而已，但如果真是要开上千个容器的话，占用空间还是太多了，最好还是 commit 一下。

    docker commit -m="Auto upgrade to v0.11.25" -a="Li Zheng" \
      55517c4d8873 flyskywhy/syncthing

这里的 55517c4d8873 是 `docker ps` 出来的 `CONTAINER ID` ，也就是说我们现在基于 `gbrks/syncthing:edge` 这个镜像修改的运行时容器现在被保存成了新镜像 `flyskywhy/syncthing` 。这里的 `edge` 是 Docker 的 tag 标签的概念，如果没有打标签，默认就是 `latest` 。也就是说后续运行前面的 `docker run` 命令时最后一个参数直接使用 `flyskywhy/syncthing` 即可。

注：尽量不要使用 `docker diff 55517c4d8873` 这样的命令查看发现存在新增的觉得多余而不想 commit 文件存在后再用

    docker run -it  --entrypoint=sh gbrks/syncthing:edge

命令登录进 shell 去使用 rm 命令删除相关文件，再 commit ，因为这可能会导致基于这新 commit 出来的镜像运行的容器无法自动运行 syncthing 。

## Syncthing 即时同步文件的方法

标准的 Syncthing 是通过轮询方式来扫描文件的改变然后再同步的，每个文件夹默认的轮询间隔是 60 秒，这个间隔值虽然可以修改为最小的 0 ，但实际测下来还是有最小十几秒、最大几百秒（同步文件夹众多情况下）的延迟。如果项目需求不能忍受该延迟或需要即时同步的，则可以再带入一个复杂度——加入同样是 Syncthing 官方开发的[syncthing-inotify](https://github.com/syncthing/syncthing-inotify)的支持。

在该网页的 releases 页面中，下载 syncthing-inotify 的 Linux 或 Windows 压缩包，解压后只需要在 Syncthing 服务器所处电脑上运行如下示例命令即可（貌似不需要在 Syncthing 终端上也运行就能双向即时同步，但如果终端上运行的不是 Syncthing APP 而是 ARM Linux Syncthing ，则不然）：

    ./syncthing-inotify -folders=3Gtemp,Test

这个示例中的 `3Gtemp` 和 `Test` 来自于 Syncthing 配置页面中的某个同步文件夹的 `文件夹标识` ，如果不加 `-folders` 参数的话则默认是对所有同步文件夹进行即时同步。

## Syncthing 减小甚至避免对闪存的损伤

Android 设备的存储类型一般是闪存，闪存最怕的是在写入时突然断电，而物联网项目中突然断电的现象是无可避免的，所以对于可能会有频繁写入动作的 Syncthing 这种软件，需要找到一个解决方法。

幸运的是，内存文件系统 tmpfs 原生存在于 Android 所用的 Linux 内核中，这样只要把 tmpfs 挂载（mount ）到经常读写临时文件的同步文件夹形成内存盘，就可以减小甚至避免对闪存的损伤（虽然 tmpfs 在内存不足的情况下也会存储到闪存中，而不像 ramfs 那样完全位于内存中，但是 ramfs 没法显示内存盘的剩余空间比如 `df` 命令显示剩余空间为 0 ，导致存储时会判断剩余空间的 syncthing 无法创建大于 0 字节的文件）。

基于 tmpfs 所创建的内存盘的大小随所需要的空间而增加或减少，可以创建多个内存盘，只要内存足够。下述示例命令就是在 Android 中使用 root 账户在当前路径中的一个文件夹 `temp/` 上挂载了一个内存盘，并让普通账户的 Syncthing APP 能够有权限读写该内存盘：

    mount -t tmpfs -o mode=0777 none temp/

缺省情况下， tmpfs 被限制为最多可使用内存大小的一半，也可以通过 size 选项来修改：

    mount -t tmpfs -o mode=0777,size=200m none temp/

由于新挂载的内存盘中是没有文件存在的，所以为了让之前已经被设置为同步文件夹的 `temp/` 能够在 Syncthing 中正常运行，还需要添加一个 `.stfolder` 文件：

    touch temp/.stfolder

只有存在了这个之前曾经自动生成过的 `.stfolder` 文件之后再启动 Syncthing APP ， Android 版的 Syncthing APP 才可避免可能的程序意外终止（闪退）。另外测试发现，如果在正常运行过程中 `umount temp/` 这样卸载，然后再次 `mount` 的， Syncthing 还能勉强运行（同步响应速度变慢）。

鉴于上述 mount 命令可以在一个挂载点上反复挂载，且为避免其它软件往该内存盘中写入太多数据导致内存较少的问题，这个 mount 命令不建议写在 Android 系统根目录的 factory_init.rc 中（这样也避免了重新编译、烧录 Android 系统），而是在与 Syncthing 配合的项目相关的 APP 中运行，当然前提是先要 ROOT 掉 Android 并给 APP 赋予 ROOT 权限。

## Syncthing APP 还是 ARM Linux Syncthing ？

Syncthing APP 只是一个调用由 Syncthing 源代码编译成的 libsyncthing.so 这个库文件的 Android 应用，对于个人操作来说是比较方便的，但对于大批量的物联网设备来说，则不太可能在这些设备上一个个去通过图形界面配置同步设备和文件夹。幸运的是，Syncthing 同时也发布着 Syncthing 源代码编译成的 ARM 架构的 Linux 版的 syncthing 可执行文件，我们可以通过在自己的 APP 中调用该可执行文件、在字符串级别摆弄其所生成的 `config.xml` ，就可以做到设备上电自动配置使用。

## 代码下载

### Syncthing 多路终端自动测试脚本
    git clone github.com/flyskywhy/syncthing-test.git
