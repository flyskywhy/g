Li Zheng <flyskywhy@gmail.com>

# React 使用详解
React 并不是简单地在 Javascript 中嵌入 HTML ，而是对 UI （包括 web 和 APP）渲染的方式进行了革新。而且， [选择 React 是商业问题而不是技术问题](https://www.sdk.cn/news/4774) 。

本文的工具安装以 Linux 为例，其它平台详见 [开始使用React Native - react native 中文网](http://reactnative.cn/docs/0.27/getting-started.html)

## 安装 node.js 及其自带的包下载工具 npm
从 [nodejs 官网](nodejs.org) 下载安装。

如果是 Linux 用户，需要手动将 node 安装位置的 `bin` 目录添加到 `$PATH` 中。

### 配置 npm 镜像
为避免后续执行 `npm install` 时因网络问题导致的下载失败，最好是配置一下镜像：

    npm config set registry https://registry.npm.taobao.org

## 安装 watchman
watchman 是由 Facebook 提供的监视文件系统变更的工具。安装此工具可以提高开发时的性能（ React Native 的 packager 可以快速捕捉文件的变化从而实现实时刷新）
### 安装依赖
    sudo apt-get install autoconf automake python-dev
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
从 [https://developer.android.google.cn](https://developer.android.google.cn/studio/index.html) 下载 sdk-tools-linux 成为比如 `~/tools/android-sdk/` ，在 `~/.bashrc` 中添加 `export ANDROID_HOME=~/tools/android-sdk` 。后续在编译各种 APP 时 `~/tools/android-sdk/tools/bin/sdkmanager` 会视需要自动下载比如 `~/tools/android-sdk/platforms/android-26/` 等。

为了让 android-sdk 中 32 位的 aapt (比如 `~/tools/android-sdk/build-tools/26.0.0/aapt` ) 能够在 64 位的 Linux 中运行，还要确保已经运行过如下命令：

    sudo apt install lib32stdc++6 lib32z1

## debug 在线运行 Android
用如下命令自动编译 apk 并运行：

    react-native run-android

它也会同时启动 native packager server , 如果没有自动启动 server , 会报错 `React Native: ReferenceError: Can't find variable: require (line 1 in the generated bundle)` ，此时就需要手动启动：

    react-native start

如果出现错误提示 “increase the fs.inotify.max_user_watches sysctl” ，则可按 [Increasing the amount of inotify watchers](https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers) 进行操作。

## release 离线打包
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

更多用法参见 [React-Native 离线打包](http://alihub.org/14659907331638.html) 。

## release 在线更新
参见 [React-Native 集成CodePush](http://alihub.org/14665598323437.html) 。

## 安装 react-dom
安装后续要安装的 react-web 的 [package.json](https://github.com/taobaofed/react-web/blob/master/package.json) 中的 `peerDependencies` 里的 `react` 和 `react-dom`，因为 react-web 相当于是 `react` 和 `react-dom` 这两个宿主的插件，想要装插件就要先装宿主。由于上面 `react-native init` 已经自动安装了 react ，所以现在只需安装 react-dom ，如果后续某个新版的 react-web 也许也能像现在 react-native 自动安装 react 一样去安装 react-dom，则此处可省：

    cd AwesomeProject
    npm install react-dom --save

## 安装 react-web
    npm install -g react-web-cli

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

## Redux
[还在纠结 Flux 或 Relay，或许 Redux 更适合你](https://segmentfault.com/a/1190000003099895)[Redux 中文文档 ](http://cn.redux.js.org/)

    npm install --save redux react-redux
    npm install --save-dev redux-devtools

## 使用 moles-web
react-web 用起来还是有点磕磕绊绊，还好携程基于 react-web 做了个高级版 moles-web ，现在已经在携程的主 App 上投入生产，详见 [Moles：携程基于React Native的跨平台开发框架](https://www.sdk.cn/news/4602) ，只是其目前最新版还未开源，可以先拿 npm 上的旧版本与 react-web 代码整合用用。
