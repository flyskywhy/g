Li Zheng <flyskywhy@gmail.com>

# React 使用详解
React 并不是简单地在 Javascript 中嵌入 HTML ，而是对 UI （包括 web 和 APP）渲染的方式进行了革新。而且， [选择 React 是商业问题而不是技术问题](https://www.sdk.cn/news/4774) 。

本文的工具安装以 Linux 为例，其它平台详见 [开始使用React Native - react native 中文网](http://reactnative.cn/docs/0.27/getting-started.html)

## 安装 node.js 及其自带的包下载工具 npm
从 [nodejs 官网](https://nodejs.org) 下载安装。

如果是 Linux 用户，需要手动将 node 安装位置的 `bin` 目录添加到 `$PATH` 中。

### 配置 npm 镜像
为避免后续执行 `npm install` 时因网络问题导致的下载失败，最好是配置一下镜像：

    npm config set registry https://registry.npm.taobao.org

## 安装 watchman
watchman 是由 Facebook 提供的监视文件系统变更的工具。安装此工具可以提高开发时的性能（ React Native 的 packager 可以快速捕捉文件的变化从而实现实时刷新）
### 安装依赖
    sudo apt-get install autoconf automake python-dev libtool pkg-config libssl-dev
### 安装 watchman, 如果出错, 查看安装依赖的详细文档
    git clone https://github.com/facebook/watchman.git
    cd watchman
    git checkout v4.6.0  # 也可以是其它的最新版本号
    ./autogen.sh
    ./configure
    make
    sudo make install

## 安装 flow
flow 是一个静态的 js 类型检查工具。你在很多示例中看到的奇奇怪怪的冒号问号，以及方法参数中像类型一样的写法，都是属于这个 flow 工具的语法。这一语法并不属于 ES 标准，只是 Facebook 自家的代码规范。所以新手可以直接跳过（即不需要安装这一工具，也不建议去费力学习 flow 相关语法）。

在终端中输入以下命令来安装flow:

    npm install -g flow-bin

## 项目名称限制
项目名称中不能有 - 这个符号。

## 安装 react-native-cli
    npm install -g react-native-cli

## 创建 react-native 项目
比如项目名称为 AwesomeProject ：

    react-native init AwesomeProject

这会自动创建 AwesomeProject 目录及其中一些文件。

从 react 15.3.0 开始，容易在应用的界面上引发巨量的 warning "You are manually calling a React.PropTypes validation" ，而且这些 warning 在 react 16 中将会变成 error ，在其它一些 react-native 第三方库解决这些问题（能使用 react 16 了）之前，可以先只用 react 15.2.1 ，所以可以指定安装依赖于 react 15.2.1 的最后一个 react-native 版本 0.31.0 ：

    react-native init --version 0.31.0 AwesomeProject

## 配置 Android 开发环境
从 [https://developer.android.google.cn/studio/index.html](https://developer.android.google.cn/studio/index.html) 下载 sdk-tools-linux 成为比如 `~/tools/android-sdk/` ，在 `~/.bashrc` 中添加 `export ANDROID_HOME=~/tools/android-sdk` 。后续在编译各种 APP 时 `~/tools/android-sdk/tools/bin/sdkmanager` 会视需要自动下载比如 `~/tools/android-sdk/platforms/android-26/` 等，如果在自动下载时出现 "You have not accepted the license agreements of the following SDK components" 的错误，则需手动运行一下 `yes | ~/tools/android-sdk/tools/bin/sdkmanager --licenses` 。

为了让 android-sdk 中 32 位的 aapt (比如 `~/tools/android-sdk/build-tools/26.0.0/aapt` ) 能够在 64 位的 Linux 中运行，还要确保已经运行过如下命令：

    sudo apt install lib32stdc++6 lib32z1

如果没有装过 jdk 的话，还需要：

    sudo apt install default-jdk

如果 `echo $SHELL` 发现是 dash 的话，后续编译时会报 `aapt: Syntax error: newline unexpected (expecting ")"` 的错误，所以还需换成 bash：

    sudo dpkg-reconfigure dash

如果是 Win10 中的 WSL ，后续编译时会报 `aapt: cannot execute binary file: Exec format error` 的错误，这是由于 [64 位的 Win10 只支持 64 位而不支持 32 位的 Linux 二进制可执行文件](https://wpdev.uservoice.com/forums/266908-command-prompt-console-bash-on-ubuntu-on-windo/suggestions/13377507-please-add-32-bit-elf-support-to-the-kernel) ，解决方法是先

    sudo apt install qemu-user

然后以 `~/tools/android-sdk/build-tools/23.0.1/aapt` 为例，把 aapt 重命名为 aapt-32 ，最后原地新建可执行脚本文件 aapt ，脚本内容为 `qemu-i386 ~/tools/android-sdk/build-tools/23.0.1/aapt-32 $*` 即可。

## debug 在线运行 Android
在 react-native 项目目录比如 `AwesomeProject/` 中用如下命令自动编译 apk 并运行：

    react-native run-android

它也会同时启动 native packager server , 如果没有自动启动 server , 会报错 `React Native: ReferenceError: Can't find variable: require (line 1 in the generated bundle)` ，此时就需要手动启动：

    react-native start

这样，当 js 代码修改后，将 Android 真机摇一摇，就能 Reload 过来最新修改的 js 代码了。

如果 `react-native run-android` 出现错误提示 “java.util.concurrent.ExecutionException: com.android.builder.utils.SynchronizedFile$ActionExecutionException: com.android.ide.common.signing.KeytoolException: Failed to create keystore.” ，则需要

    keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

并将生成的 debug.keystore 放到 `~/.android/` 中。

如果 `react-native start` 出现错误提示 “increase the fs.inotify.max_user_watches sysctl” ，则可按 [Increasing the amount of inotify watchers](https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers) 进行操作。

如果是 Win10 中的 WSL ，由于 Windows 的防火墙无法自动在 WSL 中的 Linux 开启端口时弹出对话框让用户选择是否允许，所以只有 Win10 本机才能访问该端口。为了让其它主机比如 Android 真机摇一摇后 `Dev Setting | Debug server host & port for device` 设置能够成功 Reload 到 js 代码，需要手动在防火墙中开启 native packager server 所监听的 8081 端口，方法是在 `控制面板 | Windows Defender 防火墙 | 高级安全 Windows Defender 防火墙 | 入站规则 | 新建规则` 中选择 `端口 | 8081 | 允许连接 ` ，最后填写名称比如为 `Allow localhost port 8081` 以及填写描述比如为 `port forwarding to allow external machine to access Windows 10's Windows Subsystem Linux servers` 即可。


## release 离线打包 Android
### 生成签名库,拷贝至 android/app/

    keytool -genkey -v -keystore rn-apk.keystore -alias rn-apk -keyalg RSA -keysize 2048 -validity 10000

### 设置全局变量 ~/.gradle/gradle.properties

    MYAPP_RELEASE_STORE_FILE=rn-apk.keystore
    MYAPP_RELEASE_KEY_ALIAS=rn-apk
    MYAPP_RELEASE_STORE_PASSWORD=130777
    MYAPP_RELEASE_KEY_PASSWORD=130777

### 更改 android/app/build.gradle

    signingConfigs {
        release {
            storeFile file(MYAPP_RELEASE_STORE_FILE)
            storePassword MYAPP_RELEASE_STORE_PASSWORD
            keyAlias MYAPP_RELEASE_KEY_ALIAS
            keyPassword MYAPP_RELEASE_KEY_PASSWORD
        }
    }
    buildTypes {
        release {
            ...
            signingConfig signingConfigs.release
        }
    }

### 生成 apk

    cd android
    ./gradlew assembleRelease

如果在此过程中报出 `Out of Memory Error` 的错误，则需要在 `~/.gradle/gradle.properties` 中添加类似如下内容：

    org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8

更多用法参见 [React-Native 离线打包](http://alihub.org/14659907331638.html) 。

## release 在线更新
参见 [React Native CodePush实践小结](https://segmentfault.com/a/1190000009642563) 。

## 安装 react-dom
安装后续要安装的 react-web 的 [package.json](https://github.com/taobaofed/react-web/blob/master/package.json) 中的 `peerDependencies` 里的 `react` 和 `react-dom`，因为 react-web 相当于是 `react` 和 `react-dom` 这两个宿主的插件，想要装插件就要先装宿主。由于上面 `react-native init` 已经自动安装了 react ，所以现在只需安装 react-dom ，如果后续某个新版的 react-web 也许也能像现在 react-native 自动安装 react 一样去安装 react-dom，则此处可省：

    cd AwesomeProject
    npm install react-dom --save

## 安装 react-web
    npm install -g react-web-cli

另：官方 react-web 已停止维护，可使用我维护的 https://github.com/flyskywhy/react-web 替代，或是参考另一套 https://github.com/necolas/react-native-web 。

## 创建 react-web 项目

    cd ..
    react-web init AwesomeProject

## 运行 Web
运行如下命令即可启动 webpack 调试服务器，然后在浏览器打开 localhost:3000 即可：

    react-web start

坑：有时修改了 js 文件但是 webpack 调试服务器没有自动重新 bundle ，这个 BUG 可以通过重启电脑解决。

其它可参见 [三步将 React Native 项目运行在 Web 浏览器上面](http://taobaofed.org/blog/2016/03/11/react-web-intro/)

## 打包 Web
    react-web bundle

打包完成后，文件会存放在 web/output/ 目录下面。

## 配置 iOS 开发环境
除了为 React Native [搭建开发环境](https://reactnative.cn/docs/getting-started.html) ，还需 [像 Mac 高手一样管理应用，从 Homebrew 开始](https://sspai.com/post/42924) 使用 `brew install` 、 `brew cask install` 或 `mas install` 安装各种实用工具。安装过程中最好保持翻墙状态，否则速度较慢或无法安装。另可参考 [我在 Mac 上都用什么](https://www.cnblogs.com/imzhizi/p/my-apps-on-mac.html) 一文。

    brew install mas node watchman
    brew cask install sublime-text double-commander google-chrome the-unarchiver iterm2 xquartz typora meld intelliscape-caffeine bitbar geektool turbovnc-viewer microsoft-remote-desktop-beta flux mosh inkscape gimp

注：其中 `turbovnc-viewer` 的运行需要先安装下面提到的 JAVA 环境，并运行如下语句：

    export JAVA_HOME `/usr/libexec/java_home -v 1.8`
    launchctl setenv JAVA_HOME $JAVA_HOME

* 解决 `brew install` 或 `npm install -g` 时出现的 `/usr/local/` 权限问题

如果当前不是 macOS 的第一个用户，就算已加入 admin 组，也还需要手动加入 wheel 组：

    sudo dseditgroup -o edit -a $USER -t user wheel

* 解决 `brew install` 的 git-gui 运行时容易崩溃的问题

使用其它 git 的图形化客户端替代，比如

    brew cask install fork

* 安装 JAVA 环境

如果想在 macOS 上编译 Android APP ，则还需参考 [macOS 的 JDK 安装问题 (Homebrew)](https://www.cnblogs.com/imzhizi/p/macos-jdk-installation-homebrew.html) 一文安装 JDK8

    brew cask install AdoptOpenJDK/openjdk/adoptopenjdk8

## Xcode 编译过程问题集锦
* 手工下载 `node_modules/react-native/third-party`

如果出现这个错误
```
Failed to successfully download 'boost_1_63_0.tar.gz'. Debug info:
ls: /Users/lizheng/Library/Caches/com.facebook.ReactNativeBuild/boost_1_63_0.tar.gz: No such file or directory
```
则要按照 `node_modules/react-native/scripts/ios-install-third-party.sh` 中底部的几个链接手动下载，再将下载好的文件放到 `~/.rncache/` 或 `~/Library/Caches/com.facebook.ReactNativeBuild/` 中即可用 Xcode 重新编译。

## 使用 Cocoapods 安装 iOS 第三方库

首先是安装 cocoapods 自身

    sudo gem install cocoapods

在 `ios/` 目录中运行 `pod init` 以生成 Podfile 文件，然后可以按需修改，推荐按照下面会提到的 [react-native-unimodules](https://github.com/unimodules/react-native-unimodules) 的 README.md 说的那样修改 `ios/Podfile` 。

最后就可以这样简单地安装 iOS 第三方库了（而不是像上面那样还要手工下载 `node_modules/react-native/third-party` ）:

    pod install

安装完后它会提示退出 Xcode 进程，并且下次 Xcode 需要打开 ios/ 目录中的 `.xcworkspace` 而非 `.xcodeproj` 。

一般来说，使用 `pod install` 方式的话，就不需要再运行以前安装 react-native 第三方组件经常所需的 `react-native link` 命令，虽然就算运行过好像也没事。

## Redux
[还在纠结 Flux 或 Relay，或许 Redux 更适合你](https://segmentfault.com/a/1190000003099895)

[Redux 中文文档 ](http://cn.redux.js.org/)

    npm install --save redux react-redux
    npm install --save-dev redux-devtools

## react-native-unimodules
react-native 兴起之初，各种第三方组件百家争鸣，但也良莠不齐。最近看来 react-native-unimodules 渐有一统之势，它支持许多开发 APP 时用得到的方方面面的 [Packages](https://docs.expo.io/versions/latest/bare/unimodules-full-list/) ，而且其中所谓 bare workflow 也就是不需要和 Expo 绑定的独立 Packages 已经足够多了。

如果是在 iOS 中使用 react-native-unimodules ，则必须要使用上面提到的 `pod install` 才能正常运行。

## 参考 moles-web

携程基于 react-web 做了个高级版 moles-web ，现在已经在携程的主 App 上投入生产，详见 [Moles：携程基于React Native的跨平台开发框架](https://www.sdk.cn/news/4602) ，只是其目前最新版还未开源，可以先拿 npm 上的旧版本与 react-web 代码整合用用。
