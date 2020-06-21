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

### 设置全局变量 `~/.gradle/gradle.properties`

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
    brew cask install sublime-text double-commander google-chrome the-unarchiver iterm2 xquartz typora meld dos2unix intelliscape-caffeine bitbar geektool turbovnc-viewer microsoft-remote-desktop-beta flux mosh inkscape gimp

注：其中 `turbovnc-viewer` 的运行需要先安装下面提到的 JAVA 环境，并在 macOS 自带终端中运行(在 iterm2 中运行没有效果)如下语句：

    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
    launchctl setenv JAVA_HOME $JAVA_HOME

* 解决 `brew install` 或 `npm install -g` 时出现的 `/usr/local/` 权限问题

如果当前不是 macOS 的第一个用户，就算已加入 admin 组，也还需要手动加入 wheel 组：

    sudo dseditgroup -o edit -a $USER -t user wheel

* 解决 `brew install` 卡住很久的问题

brew 在安装软件前会先尝试升级 brew 自身，这里可能是中国网络环境的原因而会卡住很久，如果不想要升级 brew 自身的，此时可以直接 `CTRL + C` 跳过，它就会自动继续去安装了。

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

另：如果按后文所说“使用 Cocoapods 安装 iOS 第三方库”，则不会存在本问题。

* 'RCTAssert.h' file not found

这是 react-native 最基本的一个 `.h` 文件，也会报错，对于苹果公司的产品真是无语了。这一般是因为 Xcode 或 macOS 的 bug ，重启 macOS 就可以了……如果使用外接鼠标的话，有时 macOS 突然会变得很卡，很难用鼠标进行移动、点击等操作，换个鼠标仍然如此，也是重启 macOS 就可以了，或是将鼠标接收器换个 USB 口，但如果换了，剩下的那个 USB 口有时无法正常连接 iPhone 进行调试……

* 尽量在 Xcode 中编辑文件内容

否则 Xcode 会不知道文件已经编辑过了。如果是在 Xcode 中编辑的话， Xcode 会自动 index 一下，然后 build 时就不会出错了。再次吐槽的是， index 和 build 的速度也太慢了。

* Timeout waiting for modules to be invalidated

曾经在模拟器中安装调试运行时碰到过这个错误，按 https://stackoverflow.com/questions/46206867/timeout-waiting-for-modules-to-be-invalidated 中的说法是需要将真机的 WiFi 连到与 macOS 同一个局域网中，不过我的情况是将模拟器换成真机后就好了，搞不懂背后真正的原因是啥。

* 真机调试时需要在 Xcode 的菜单 `Preferences | Accounts` 那里添加 Apple ID ，并在 Xcode 的主界面中的 Project 的某个 Target 的 'Signing & Capabilities' 那里选择相应的 Team 。

但是，千万要记得所添加的那个 Apple ID 就是今后将要用来发布到 App Store 的账号，否则如果先用自己个人的免费账号在真机上进行调试了，那么苹果服务器就会自动将你所调试的 APP 的 PRODUCT_BUNDLE_IDENTIFIER 比如 com.domainname.appname 作为 APP ID 保存到你的个人账号名下了，那样等你后续用公司的收费账号在 https://developer.apple.com/ 上申请 Identifiers 时，它就会说 "An App ID with Identifier 'com.domainname.appname' is not available" ，而你用免费账号登录 https://developer.apple.com/ 的话根本连 Identifiers 的进入按钮都看不见更别说删除该 APP ID 了，这样你只能让你的公司账号下的 PRODUCT_BUNDLE_IDENTIFIER 改名……苹果公司又一个反人类的设计。

第一次打包 APP 以便在真机上运行时， Xcode 会弹出对话框让你输入苹果电脑登录密码以便访问钥匙串，你确定一次后，又回弹出一次，再确定，再弹出，次数多到让你以为你输错了苹果电脑登录密码……一共会弹出 10 次左右的对话框……

* 添加 Apple ID 时报错说“未知错误”

如果局域网不太稳定（比如路由器再加一个 WiFi 放大器）就容易出现这个问题，可以通过临时连接手机热点来简单解决之。

* 开发时也需要连接苹果公司服务器

在 Xcode 中点击 Run 按钮第一次将 APP 在真机上运行时，当真机界面上出现 APP 图标时， Xcode 会弹出对话框，按照其提示到真机的 `设置 | 通用 | 设备管理 | 开发者 APP` 中进行验证，然而接着关闭 Xcode 中的对话框后， Xcode 并不会接着继续启动 APP 进行调试，如果你想在 Xcode 中看到调试信息的话，你就不得不再次点击 Run 按钮自动 build 安装共 3 分钟后才行，真是浪费生命。而更吊诡的是，如果后续某个时间你的路由器因某种原因与互联网连接断开，那么连接在路由器的 WiFi 上的真机中的 APP 又变成了需要验证的状态，也就是你没有互联网的话就连代码调试都无法做到，苹果公司的服务器时刻在看着你……

* 用 Debug 配置进行调试

由于使用 Release 配置点击 Run 按钮的话需要等待半小时，所以调试时记得将 `Produce | Scheme | Edit Scheme | Run | Build Configuration` 设置为 Debug 。其实就算使用 Debug ，运行也需要 3 分钟，哪像 react-native 开发时只需要手机摇一摇花 3 秒钟就能看到 JS 代码所做的改变。真为那些全部代码都使用 Xcode 原生编写的开发人员感到悲哀——每天不知道浪费了多少个 3 分钟。还好我只需要捏着鼻子偶尔用连语法都是反人类的 ObjectC 语言在 Xcode 中做一些原生适配，就又可以愉快地去写 JS 代码了。

* 项目所在绝对路径中不应该有空格，否则编译会失败

* 配置 node 路径

如果没有标准化安装 nodejs ，比如 `brew install node@10` 这种方式安装的，则就算已经在 `.bash_profile` 中 `export PATH=/usr/local/opt/node@10/bin:$PATH` 了，也还是会在真机编译时报 `Can't find 'node' binary to build React Native bundle` 这样的错误，此时需要按提示到 Xcode 的 Project 的 `Build Phases | Bundle React Native code and images` 那里将 `export NODE_BINARY=node` 改为 `export NODE_BINARY=$(which node)` 。或者还有一种方法 `ln -s $(which node) /usr/local/bin/node` 。

* 为 Xcode 添加 iOS-DeviceSupport

如果真机调试运行时出现比如 `This iPhone 7 (Model 1660, 1778, 1779, 1780) is running iOS 13.2.3 (17B111), which may not be supported by this version of Xcode. An updated version of Xcode may be found on the App Store or at developer.apple.com.` 这样的错误提示，它的意思是当前版本的 Xcode 不支持真机上的 iOS 操作系统版本。调试一个手机 APP 还必须要 IDE 支持手机操作系统的版本，这样的反人类设计恐怕也只有苹果公司才做得出来。可以如提示中所说升级 Xcode 自身，但 Xcode 安装包要 7 个多 GB ，而且偶尔某个版本的 Xcode 会出现一些奇奇怪怪的 BUG ，所以最简洁的方式其实是为当前版本的 Xcode 的安装目录某个地方多添加一个比如 13.2 目录即可。

从 https://github.com/iGhibli/iOS-DeviceSupport/tree/master/DeviceSupport 下载比如 `13.2(FromXcode11.2.1(11B500)).zip` ，解压出 `13.2` 目录， `sudo mv 13.2 /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/` ，最后重启 Xcode 并重连手机即可。

* `dyld: Library not loaded: /usr/local/opt/icu4c/lib/libicui18n.66.dylib`

如果在 Xcode 持续开启的状态下，比如为了满足 App Store 上预览视频的分辨率要求而在终端里 `brew install ffmpeg` 用于视频转码，然后一转眼 Xcode 运行 `Product | Archive` 打包到 node 步骤时即可能报上述错误，其原因是 node 和 ffmpeg 都依赖 icu4u ，而一般情况下 node 是比较早之前安装的，那时候自动安装的 icu4u 版本如果比现在 ffmpeg 触发安装的 icu4u 版本旧的话，就会出现本问题。解决的方法是重新启动 Xcode 。

## App Store 反人类集锦
* 难以理解的开发证书、生产证书、描述文件

不像 Android 的 apk 只需要命令行生成一个 key 用来签名就可以发布到 Google PLAY 了，你需要浪费生命中的几个小时甚至几天来理解 [iOS开发证书、bundle ID、App ID、描述文件、p12文件，企业证书打包发布，及过期处理](https://blog.csdn.net/Bolted_snail/article/details/80764572) 、 [iOS开发者证书申请及应用上线发布详解](https://www.cnblogs.com/ioshe/p/5481456.html) 、 [ios开发证书的坑](https://www.jianshu.com/p/a81c01323a89) 这些文章并进行相关操作。

其中一个需要理解的是， Xcode 第一次连接真机进行调试时，它会询问你是否将真机加入设备列表以便放入描述文件，在你点击确定后，它其实偷偷摸摸将你的真机的 UUID 放到了 https://developer.apple.com/account/resources/devices/list ，并且自动为你生成了调试用的描述文件，里面内含真机的 UUID 信息，也就是说使用这个描述文件打包的 APP 只能在这个真机运行，而 https://developer.apple.com/account/resources/profiles/list 中的是发布用的描述文件，里面不含真机的 UUID 信息，也就是说使用这个描述文件打包的 APP 可以在任何设备上运行。所以我们不用关心网页上的设备列表，只需要关心在网页上创建描述文件并下载以便发布即可。

* 没有提示自动审核

如果在 Xcode 中用 `Window | Organizer | Distribute App` 成功上传到了 App Store 中，但却无法在 https://appstoreconnect.apple.com/ 的任何地方找到该构建版本的信息，这一般是因为苹果公司服务器自动审核你上传的 ipa 后发现了问题，所以你需要到相关邮箱中等待苹果公司服务器自动发来的电子邮件。问题是没有任何提示告诉你需要到邮箱中等待……

* 不会自动选择构建版本

即便你解决了自动审核提出的问题，也重新上传到 App Store 中了，而且也能在 https://appstoreconnect.apple.com/ 的 TestFlight 和活动中看到该构建版本的信息了，但你还是需要去点击“构建版本”文字旁边的 + 号进行选择才能准备“提交以供审核”。

* 出口合规证明信息

需要到 https://appstoreconnect.apple.com/ 的 TestFlight 中进行“出口合规证明信息”，说是

    您的 App 是否使用加密？即使您的 App 只使用了 Apple 操作系统中的标准加密，也请选择“是”。
    如果您正在使用 ATS 或调用 HTTPS，则您必须向美国政府提交年终自行分类报告。

不过正像 https://stackoverflow.com/questions/45008590/itunesconnect-requires-me-to-submit-year-end-self-qualification-report 里面有人提到的，如果美国政府相关机构不对我们的申请进行回复，难道就不上架 App Store 了？实际上从 [App Store 上架关键步骤：出口合规信息、内容版权、广告标识符的选择](http://zhanglinhai.com/archives/689) 一文来看，这个现在可能已经没人真正去管了。所以我们可以按照 [iOS app TestFlight 缺少出口合规证明](https://www.jianshu.com/p/edc246feed9c) 所说在 Info.plist 中设置 `<key>ITSAppUsesNonExemptEncryption</key><false/>` 键值对，这样我们下次上传构建版本后就不会看到这个“出口合规证明信息”了。

* App 预览和截屏

要上传或查看预览视频，只能使用 Safari 浏览器，用 Chrome 都不行……

## App Store 更新 APP 流程
前文提到了首次上架 APP 时的一些繁琐操作。这里再简单罗列下更经常用到的更新 APP 的流程，以尽量从苹果公司手里挽回点宝贵的生命……

在 https://appstoreconnect.apple.com/apps 中的 “App Store” 那里新增一个版本号比如 1.2 ，并在 project.pbxproj 中的 MARKETING_VERSION （也就是 Xcode 的主界面中的 Project 的某个 Target 的 General 那里的 Version ）处也写上相同的版本号 1.2 ，以及在 CURRENT_PROJECT_VERSION （也就是 Xcode 的主界面中的 Project 的某个 Target 的 General 那里的 Build ）中写上比如 1.2.0 （如果审核被拒了，只要简单修改成比如 1.2.1 就可以再次上传）

    cd ios
    pod install

在 Xcode 的主界面中的 Project 的某个 Target 的 'Signing & Capabilities' 那里选择相应的 Team 。

将 Xcode 菜单 `Produce | Scheme | Edit Scheme | Run | Build Configuration` 设置为 Release 。

在 Xcode 运行 `Product | Archive` 打包。

在 Xcode 中用 `Window | Organizer | Distribute App` 上传到 App Store 中。

上传后可以在 https://appstoreconnect.apple.com/apps 中的 “活动” 那里看到正在被自动审核（如果没看到，就要去查你的邮箱是否有苹果公司发来的邮件了），然后大概几分钟后自动审核成功，就能在 “App Store” 那里的 “构建版本” 旁边看到出现一个 + 号了，点击选择后，并且填写 “此版本的新增内容” ，就可以点击“存储”和“提交以供审核”按钮了。

## 使用 Cocoapods 安装 iOS 第三方库

首先是安装 cocoapods 自身

    sudo gem install cocoapods

在 `ios/` 目录中运行 `pod init` 以生成 Podfile 文件，然后可以按需修改，推荐按照下面会提到的 [react-native-unimodules](https://github.com/unimodules/react-native-unimodules) 的 README.md 说的那样修改 `ios/Podfile` 。除了 react-native-unimodules 外，在 react-native@0.60 及更高版本一般是不需要修改 `ios/Podfile` 的。

最后就可以这样简单地安装 iOS 第三方库了（而不是像前文那样还要手工下载 `node_modules/react-native/third-party` ）:

    pod install

安装完后它会提示退出 Xcode 进程，并且下次 Xcode 启动后需要 `Open another project...` 打开 `ios/` 目录中的 `.xcworkspace` 而非 `.xcodeproj` 。

使用 `pod install` 方式的话，就不需要再运行以前安装 react-native 第三方组件经常所需的 `react-native link` 命令，如果曾经运行过，则需要 `react-native unlink` 。

如果 `pod install` 速度很慢或者干脆无法完成，可以参考 [清华大学开源软件镜像站 CocoaPods 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/CocoaPods/)

    cd ~/.cocoapods/repos
    pod repo remove master
    git clone --depth 1 https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git master

后续如果想要更新，只需

    cd ~/.cocoapods/repos/master
    git pull

即可。最后进入自己的工程，在自己工程的 podFile 第一行加上：

    source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

然后就可以正常 `pod install` 了（第一次可能需要删除已经存在的 Podfile.lock 文件）。

另外，有时候比如 `git reset` 到某个提交点后做 `pod install` 时出现

    NoMethodError - undefined method `each' for nil:NilClass

的错误，这一般也是需要删除 Podfile.lock 文件。

### 一些 Cocoapods 使用技巧

`pod install` 背后的原理其实就是生成了一个 `ios/Pods/` 目录，并在里面自动放入或删除各个第三方库的 `.h` 头文件及编译配置文件。 `.h` 头文件所在的目录名就是相应第三方库的 `.podspec` 文件中写明的 `name` 字段，这样你自己的源代码或其它第三方库就能简单地以 `<SomeName/some.h>` 来调用该库的功能了。

`.podspec` 文件中的 `source` 字段虽然是必须的，但只要你自己的源代码并不打算发布到 cocoapods 则 `source` 字段里面的内容是可以瞎写的，因为就算你写了个不存在的 `.git` 网络链接， `pod install` 仍然会从当前硬盘中该 `.podspec` 文件所在路径中软链接 `source_files` 字段指定的 `.h` 头文件到 `ios/Pods/` 相应目录中。

`.podspec` 文件中的 `source_files` 字段中的路径必须是当前 `.podspec` 文件所在路径及其子目录，如果用 `../` 来指明上层目录的话，虽然 `pod install` 时不会报错，但实际上并没有任何 `.h` 文件被软链接过去导致后续编译失败。

如果你有自己的带有 `Headers/` 目录的 pod 库比如 `SomeFrame.framework` ，也有使用到该 framework 的自己的另一个 pod 源代码比如 `SomeSource` ，而且这两者都不打算发布到 cocoapods ，则除了在 `Podfile` 中将这两个 pod 都写进去之外， 还需要在 `SomeSource` 的 `.podspec` 文件中写明 `s.dependency 'SomeFrame'` 语句，否则虽然 `pod install` 时不会报错，但后续在编译到 `SomeSource` 时会报错说找不到 `<SomeFrame/some.h>` 文件。这里也可以看到苹果公司编译系统一个反人类的设计（另一个反人类的是 objectC 中的方括号 [] 函数调用语法）：你无法成功 `#import <SomeFrame.framework/Headers/some.h>` ，而只能在如上所说 `s.dependency 'SomeFrame'` 之后才能成功 `#import <SomeFrame/some.h>` ，虽然实际上硬盘里的 `some.h` 并不存在于任何叫做 `SomeFrame/` 的目录中。

`pod install` 运行结束后可能会有一些警告提示 `target overrides` ，这可以参考 [解决使用 CocoaPods 执行 pod install 时出现 - Use the `$（inherited）` flag ... 警告](https://www.jianshu.com/p/dfb2a5834cd0) 。

可以参阅 [Podfile文件用法详解](https://www.jianshu.com/p/b8b889610b7e) 等文章。

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
