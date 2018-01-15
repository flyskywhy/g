Li Zheng <flyskywhy@gmail.com>

react-native 的 Android 开发在 Ubuntu 上很方便，至少个人觉得比 macOS 方便。在 Ubuntu 上的开发方法可参见 [React使用详解](React使用详解.md) 。偶尔在 macOS 上调试 iOS 版然后在 macOS 上配合 CI 自动编译出 .ipa 文件的方法参见本文。本文可用于 macOS 真机或虚拟机。

## Xcode
按照 macOS 弹出的提示升级 macOS 系统，因为运行最新的 Xcode 会需要最新的 macOS 。

按照 macOS 弹出的提示升级 Xcode 软件，因为编译最新的 react-native 会需要最新的 Xcode 。

## node
先按照 [https://brew.sh](https://brew.sh) 上的提示安装 brew 这个在 macOS 上安装各种开源软件的包管理器，再使用如下命令安装 node ：

    brew install node

brew 在安装 node 前会先尝试升级 brew 自身，这里可能是中国网络环境的原因而会卡住很久，此时可以直接 `CTRL + C` 跳过，它就会自动继续去安装 node 了。

## react-native
使用如下命令安装 react-native 编译、运行 iOS 版所需的环境：

    npm config set registry https://registry.npm.taobao.org --global
    npm install -g react-native-cli
    brew install watchman

## gitlab-runner
安装一些 CI 脚本中可能用得到的工具：

    brew install wget

这里以 gitlab 自带的 CI 为例，按照 [Install GitLab Runner on macOS](http://docs.gitlab.com/runner/install/osx.html) 一文在 macOS 中安装、配置 gitlab-runner ，另可参见 [GitLab使用详解](../../配置管理/Git/GitLab使用详解.md) 中的“配置 Runner”小节。

需要在 macOS 中设置好开机时用当前账户自动登录，方法是在 macOS 中 `System Preferences | Users & Groups | Login Optinos | Automatic Login` 。

gilab-runner 会自动创建两个目录 `~/builds/` 和 `~/cache/` 进行工作。

## 远程登录
虚拟机中的 macOS 运行速度较慢，此时有些命令行操作用 ssh 远程登录过去更方便，方法是在 macOS 中 `系统偏好设置 | 选择共享 | 点击远程登录` 。

## 安装证书以进行 xcodebuild
常见的情况是在一台 macOS 真机上调试好了，拿到 CI 用的 macOS 虚拟机中进行编译，此时需要在 macOS 虚拟机中安装从 macOS 真机中导出的证书。

### .mobileprovision
从 macOS 真机中导出 `.mobileprovision` 文件，在 macOS 虚拟机中双击该文件，此时就能在 Xcode 中看到这个 provision 了。

### .p12
从 macOS 真机中导出 `.p12` 文件，在 macOS 虚拟机打开 `Applications | Utilities | Keychain Access` ，进入 其中的 `System | Certificates` ，然后将 `.p12` 文件拖进去，最后在其中确认此刚导入的证书所对应的 `private key` 的 `Access Control` 中 `Allow all applications to access this item` 。

### 命令行编译 iOS 版
在参考了[使用 xcodebuild 从 archive 导出 ipa](https://blog.reohou.com/how-to-export-ipa-from-archive-using-xcodebuild/) 一文后，发现可以用 `xcodebuild archive -scheme YourProject -destination generic/platform=iOS -archivePath bin/YourProject.xcarchive -quiet` 这个命令来生成 `YourProject.xcarchive` 。

按照 [Xcode9 xcodebuild export plist 配置](http://www.jianshu.com/p/6b68cd9307bc) ，先用图形界面的 Xcode 的 `Product | Archive` 打包完成后执行export操作（其中会需要你手动选择你的相关 provison profile 等信息）， Xcode 会自动生成 ExportOptions.plist 文件，然后就可以用 `xcodebuild -exportArchive -archivePath bin/YourProject.xcarchive -exportPath bin/YourProject -exportOptionsPlist ExportOptions.plist` 这个命令来生成 ipa 文件了。

## 让 macOS 虚拟机无界面持续运行
用于 CI 的 macOS 虚拟机无需一直显示着图形界面。如果是用普通的 ssh 远程登录到一台 Ubuntu 上再用 `virtualbox &` 开启的 macOS 虚拟机，此时关闭 ssh 后， virtualbox 也会自动退出。因此理想方式是用 `vboxmanage startvm macOS --type headless` 命令。这个命令还有一个额外的好处，就是之后再用 virtualbox 打开的图形界面上不是“启动”而是“显示” macOS ，此时“显示”出来的 macOS 图形界面操作起来不会很卡顿。

## 让 macOS 虚拟机矫正好时间
由于 macOS 在虚拟机中不会时刻矫正时间，所以有时启动虚拟机后时间不正确，这会使一些工具比如阿里云 OSS 的命令行工具 ossutilmac64 运行不正常，解决方法是在 macOS 虚拟机中用 `sudo visudo` 命令添加 `%staff          ALL = NOPASSWD: /usr/sbin/ntpdate` ，这样就可以在 CI 脚本中用 `sudo ntpdate -u time.apple.com` 来矫正时间，随后就可以在 CI 脚本中用 `/usr/local/bin/ossutilmac64` 来将自动编译出来的文件上传到阿里云 OSS 中了。
