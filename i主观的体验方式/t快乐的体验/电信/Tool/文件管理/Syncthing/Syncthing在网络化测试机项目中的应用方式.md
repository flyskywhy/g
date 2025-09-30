Li Zheng flyskywhy@gmail.com

# Syncthing 在网络化测试机项目中的应用方式

参考[Syncthing 在网络控制相关项目中的应用方式](Syncthing在网络控制相关项目中的应用方式.md)一文，网络化测试机的基本工作流程是一个中心 Linux/Windows 服务器向若干个 Android 终端发送测试数据，然后每个终端再通过自身的串口下载到测试机中，接着终端通过串口接收测试结果并发送回服务器。

## 基本思路

* 服务器发送的文件名为`user{UserIdNum}.{FileCount}.{Command}.synciot`。这里的`UserIdNum`使用本系统的众多用户中的一个用户的数字序号；这里的`FileCount`是除了本`.synciot`文件外，其它附带的文件比如一些待测试文件的总数；这里的`Command`是某个命令比如`start`或者`stop`。
* 终端回应的文件名为`out{UserIdNum}.{FileCount}.synciot`。这里的`FileCount`是除了本`.synciot`文件外，其它附带的文件比如一些测试结果文件的总数。
* 轮询，当发现新增`.synciot`文件且文件名没有前缀`.syncthing.`的`FileCount`个其它文件也出现了，即表明进入接收完成状态。

## 服务器行为

### 手动
服务器上除了安装 Syncthing 外，不需要编写软件，只需要操作文件管理器即可。

* 网络化测试机操作人员在配置好的同步目录比如`~/synciotNTM/sync/1/`中放入`in/`目录，并在其中放入`user0.0.start.synciot`文件。
* 操作人员检查发现该目录中`in/`目录不见了，取而代之的是一个类似`20160301141612/`这样的目录及其中的`out0.1.synciot`文件 和`in/`目录，就知道测试完成了。`out0.1.synciot`文件名中文件总数 1 指的是终端上的 Synciot Client APP 计算发现`20160301141612/`目录中有 1 个文件`user0.0.start.synciot`。
* 操作人员应该及时将`~/synciot/sync/1/`目录中的类似`20160301141612/`这样的目录移动到某个存档目录中，因为 Synciot Client APP 在设备重启时会自动清空该目录。

### 自动 Synciot Server
使用 Synciot 软件可以做到自动管理 Syncthing 的行为。

#### Administrator

* 管理员主要使用`http://服务器地址:7777/`这个界面操作 server，每个 server 对应着一个具体项目比如`网络化测试机`。

#### User

* 操作人员主要使用`http://服务器地址:7777/user-网络化测试机.html`这个界面操作`网络化测试机`中的各个 client。
* 操作人员主要使用`ftp://服务器地址:21/`这个界面操作映射到比如`synciotNTM/io/user0/`的目录，这个目录中存在有`in/`目录和类似`out/7/20160301141612/`这样的目录 。
* 当操作人员点击 User 界面中的`运行`按钮时，就会发现 User 界面中某个 client 的状态变成了`同步中`。这背后产生的动作是：Synciot 将会自动把创建了例如`user0.x.start.synciot`（这里的 x 是`synciotNTM/io/user0/in/`中待测试文件的数量）的`synciotNTM/io/user0/in/`复制到操作人员在 User 界面所勾选的各台终端对应的同步文件夹中比如`synciotNTM/sync/7/in/`中，然后清空`synciotNTM/io/in/`。
* `停止`按钮是不需要在`synciotNTM/io/in/`放入额外文件的。当操作人员点击 User 界面中的`停止`按钮时，就会发现 User 界面中某个 client 的状态也变成了`同步中`。这背后产生的动作是：自动生成了`user0.0.stop.synciot`文件。
* 当操作人员检查发现 User 界面中某个 client 的状态变成了`1`或者更大的数字，就知道测试完成了。这背后产生的动作是：自动把比如`synciotNTM/sync/7/in/20160301141612/`移动成为了`synciotNTM/io/user0/out/7/20160301141612/`

#### Connector

* Synciot 服务端软件自动把`synciotNTM/connector/`中出现的比如`W4DMSTR-4NH7FWZ-WF2ZS4M-LJDRUMR-O34EXHV-E2MZIPL-7KWPXJ3-5CEUMAE`文件的文件名添加到 syncthing 的`config.xml`中。

## Synciot Connector APP
该 APP 可以方便安装人员将成百上千个终端联接到服务器上而不需要系统管理员花时间进行处理，系统管理员唯一需要的是在 Syncthing 的网页界面中把仅有的几个安装人员的 Connector APP 中的 Syncthing device id 与服务器联接，这也是避免任意人员只要安装 Connector APP 就能联接终端和服务器的情况的发生，提高了安全性。

* Synciot Connector APP 自动把它扫描或人工输入得到的终端的 Syncthing device id 保存为文件并同步到`synciotNTM/connector/`中。

## 终端行为 Synciot Client APP

* 终端开机后，自动运行 APP。
* APP 检查发现工作目录（即在终端的 Syncthing 里设置好的一个同步目录）比如`/sdcard/synciot/sync/`中出现了比如`in/user0.1.start.synciot`文件及一个`in/test.dat`文件，就建立`20160301141612/`目录，并把`test.dat`文件并通过串口传输到测试机中进行测试，然后从串口获得测试数据后将结果保存在`20160301141612/`目录中的一个文件中，最后移动`in/`目录到`20160301141612/`目录以及在`20160301141612/`目录中建立`out0.3.synciot`文件 。

## TODO

* Synciot Connector APP 还未开发。

## 代码下载
    git clone github.com/flyskywhy/synciot.git
