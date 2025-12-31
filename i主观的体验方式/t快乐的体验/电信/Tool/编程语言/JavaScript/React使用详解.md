Li Zheng flyskywhy@gmail.com

# React 使用详解
React 并不是简单地在 Javascript 中嵌入 HTML ，而是对 UI （包括 web 和 APP）渲染的方式进行了革新。而且， [选择 React 是商业问题而不是技术问题](https://developer.aliyun.com/article/115052) 。

本文的工具安装以 Linux 为例，其它平台详见 [开始使用React Native - react native 中文网](http://reactnative.cn/docs/0.27/getting-started.html)

## 安装 node.js 及其自带的包下载工具 npm
从 [nodejs 官网](https://nodejs.org/dist/) 下载安装。 React Native 的某些 0.6x 版本还能在 nodejs v10 上面工作，更高的则至少需要 nodejs v15（nodejs 从 v16 开始不能再正常运行于 Win7 ）。

如果是 Linux 用户，需要手动将 node 安装位置的 `bin` 目录添加到 `$PATH` 中。

### 配置 npm 镜像
为避免后续执行 `npm install` 时因网络问题导致的下载失败，最好是配置一下镜像：

    npm config set registry https://registry.npm.taobao.org

或是暂时让电脑进行系统性翻墙比如运行翻墙 VPN 或是在系统代理设置中设置翻墙服务器的代理 `IP:port`

或是暂时让电脑只在 `npm install` 时才翻墙，也就是在 `~/.npmrc` 中添加
```
    //timeout=200000
    https-proxy=http://翻墙服务器的代理IP:port
```
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
```
    npx @react-native-community/cli init AwesomeProject --package-name com.foobar.awesome --version 0.71.6 --pm npm
```
这会自动创建 AwesomeProject 目录及其中一些文件。

既然 react native 开发团队现在推荐使用 expo ，那么一般来说还需要安装 expo ：
```
    npx install-expo-modules
```
它会自动根据 AwesomeProject 的 package.json 中的 react-native 的版本按照 [VersionInfo](https://github.com/expo/expo/blob/main/packages/install-expo-modules/src/utils/expoVersionMappings.ts) 中的规则安装匹配的 expo ，以及更改各种源代码，所以下次升级 react-native 时记得先 `git revert` 这个提交点。

expo 自己所提出的 EAS 的编译方式，与 expo 的服务器联系有点紧密，为避免编译环境太过依赖外部，这里仍以介绍传统的 react-native 编译方式也就是 expo 文档中所说的 bare 方式为主。

从 react-native 0.79 和 expo 53 开始，对于 Android 来说，会自动启用 expo 自己编译方式所用的一套 autolink 规则，此时如果直接使用 bare 的 `react-native run-android` 则会曝出编译错误 `Could not find expo.modules.asset:expo.modules.asset:11.1.7` ，此时如果强行在 `node_modules/expo/android/build.gradle` 中将 `useLegacyAutolinking` 设为 true ，虽然能通过编译，但是运行时会出现 `java.lang.NoClassDefFoundError: Failed resolution of: Lexpo/modules/core/interfaces/ReactActivityHandler$DelayLoadAppHandler` 的闪退问题，最终发现，只要类似在 [android/settings.gradle](https://github.com/flyskywhy/GCanvasRNExamples/blob/master/android/settings.gradle) 中添加
```
        // to fix `Could not find expo.modules.asset:expo.modules.asset`
        maven { url("$rootDir/../node_modules/expo-asset/local-maven-repo") }
        maven { url("$rootDir/../node_modules/expo-file-system/local-maven-repo") }
        maven { url("$rootDir/../node_modules/expo-font/local-maven-repo") }
        maven { url("$rootDir/../node_modules/expo-keep-awake/local-maven-repo") }
```
即可。

上述几个 expo 组件是 `npx install-expo-modules` 时自带的，如果要安装其它 expo 组件，可以通过比如 `npx expo install expo-camera` 这样的方式来安装，如果安装时出现 `--legacy-peer-deps` 报错，则需要 `npm install --legacy-peer-deps expo-camera`。安装完成后也要象上面一样添加比如
```
        maven { url("$rootDir/../node_modules/expo-camera/local-maven-repo") }
```

至于有一条命令叫做 `npx expo prebuild` ，其实是 expo 的非 bare 方式是不存在 android 和 ios 目录的，然后此命令会自动根据 `app.json` 中类似下面 `+` 新增的配置信息生成那两个目录，参见 [RN/Expo项目本地打包成APK](https://www.cnblogs.com/shengoasis/p/18800767) 一文。
```
 {
   "name": "FOO BAR",
-  "displayName": "FOO BAR"
+  "displayName": "FOO BAR",
+  "android": {
+    "package": "com.carefree.foobar"
+  },
+  "ios": {
+    "bundleIdentifier": "com.carefree.foobar"
+  }
 }
```
## 关于 react-native 版本升级
### RN 自身的升级方法
一个简洁明了的方式是使用 Git 自带的 `cherry-pick` 功能。

1. 使用 `git checkout --orphan gh-pages RnUpgrade` 在自己的仓库中建立一个独立的分支 `RnUpgrade`

2. 在临时目录中运行 `npx @react-native-community/cli init AwesomeProject --package-name com.foobar.awesome --version 0.71.6 --pm npm` ，将得到的所有文件和目录除了 `.git/` 、 `node_modules/` 和 `package-lock.json` 以外统统移过来在 `RnUpgrade` 分支中创建与你主分支相同 RN 版本的提交点 A

3. 删除当前处于 `RnUpgrade` 分支时除了 `.git/` 外的所有文件和目录，但不进行提交

4. 在临时目录中运行 `npx @react-native-community/cli init AwesomeProject --package-name com.foobar.awesome --version 0.70.5 --pm npm`  ，将得到的所有文件和目录除了 `.git/` 、 `node_modules/` 和 `package-lock.json` 以外统统移过来在 `RnUpgrade` 分支中创建你希望升级到的 RN 版本的提交点 B

5. 切换到主分支，用 Git 的 `cherry-pick` 功能将提交点 B 应用过来，然后就会出现很多冲突，此时参考原提交点 B 的变化或是更直观的 [React Native Upgrade Helper](https://react-native-community.github.io/upgrade-helper) 中的变化，解决这些冲突即可

### 其它第三方组件升级
一般来说第三方组件的 `README.md` 会描述版本对比，有些则可能需要查探一番比如 [react-native-reanimated](https://github.com/software-mansion/react-native-reanimated/blob/main/packages/react-native-reanimated/compatibility.json) 里列出了对应哪个 RN 版本应该安装哪个版本。


## 配置 Android 开发环境
从 [https://developer.android.com/studio#cmdline-tools](https://developer.android.com/studio#cmdline-tools) 下载 Command line tools 成为比如 `~/tools/android_sdk/cmdline-tools/latest/` ，在 `~/.bashrc` 中添加 `export ANDROID_HOME=~/tools/android-sdk` 。后续在编译各种 APP 时 `~/tools/android-sdk/cmdline-tools/latest/bin/sdkmanager` 会视需要自动下载比如 `~/tools/android-sdk/platforms/android-26/` 等，如果在自动下载时出现 "You have not accepted the license agreements of the following SDK components" 的错误，则需手动运行一下 `yes | ~/tools/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses` 。

为了让 android-sdk 中 32 位的 aapt (比如 `~/tools/android-sdk/build-tools/26.0.0/aapt` ) 能够在 64 位的 Linux 中运行，还要确保已经运行过如下命令：

    sudo apt install lib32stdc++6 lib32z1

如果没有装过 jdk 的话，还需要：

    sudo apt install default-jdk

或是到 [https://jdk.java.net/archive/](https://jdk.java.net/archive/) 手动下载所需 JDK 版本并配置好`JAVA_HOME` 这个环境变量。

低于 0.67 版本的 React Native 需要 JDK 1.8 版本（官方也称 8 版本），否则需要 11 版本或更高，比如 0.73 版本开始需要 JDK 17 。

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

新版本的 `react-native start` 已经不会在终端窗口中打印 `console.log` 等调试信息，而是打印在 chrome 调试窗口中，如果想要继续在终端窗口中打印的，可以使用：
```
    react-native --client-logs
```
或
```
    npx @react-native-community/cli start --client-logs
```
或
```
    npx expo start
```
这样，当 js 代码修改后，将 Android 真机摇一摇，就能 Reload 过来最新修改的 js 代码了。背后的动作实际上是在 Reload 的时候 packager server 实时生成了一个 `index.android.bundle` 被下载到 Android APP 中。 react native 的 LogBox 也就是出错时或 `console.warn` 在 APP 界面上的打印信息中有指明文件名和行数，如果文件名是 `index.android.bundle` 的话，则可以比如用 `wget http://localhost:8081/index.android.bundle` 命令下载到电脑中查看，此时需要注意的是不要下载到你启动 `react-native start` 的目录中比如 `YOUR_PROJECT/index.android.bundle` ，否则后续你对代码的更改再也不会被打包为最新的 `index.android.bundle` 因为 `packager server` 此时就像一个 web server 一样直接将现存的 `YOUR_PROJECT/index.android.bundle` 提供给 Android APP 或 wget 。

如果 `react-native run-android` 出现错误提示 “java.util.concurrent.ExecutionException: com.android.builder.utils.SynchronizedFile$ActionExecutionException: com.android.ide.common.signing.KeytoolException: Failed to create keystore.” ，则需要

    keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

并将生成的 debug.keystore 放到 `~/.android/` 中。

如果 `react-native run-android` 时因网络问题导致 gradle 这个编译工具自身都下载失败，则可以暂时让电脑进行系统性翻墙比如运行翻墙 VPN 或是在系统代理设置中设置翻墙服务器的代理 `IP:port` ，或是在此时会发现新生成了一个目录比如 `~/.gradle/wrapper/dists/gradle-6.2-all/dvufqs6kielxeao781pmk5huj/` ，你可以删除该目录中的 `gradle-6.2-all.zip.part.0` ，然后在可以翻墙的浏览器中下载 `android/gradle/wrapper/gradle-wrapper.properties` 中的 `services.gradle.org/distributions/gradle-6.2-all.zip` 文件到该目录中，最后重新 `react-native run-android` 即可，或者干脆使用镜像地址 `mirrors.cloud.tencent.com/gradle/gradle-6.2-all.zip` 替换进 `gradle-wrapper.properties` 中。

如果 `react-native run-android` 时因网络问题导致 gradle 这个编译工具报出一些第三方库下载失败，则可以暂时让电脑进行系统性翻墙比如运行翻墙 VPN 或是在系统代理设置中设置翻墙服务器的代理 `IP:port` ，或是暂时让电脑只在运行 gradle 时才翻墙，也就是在 `~/.gradle/gradle.properties` 中添加

    systemProp.https.proxyHost=翻墙服务器的代理IP
    systemProp.https.proxyPort=翻墙服务器的代理port

或是在 `build.gradle` 中添加下面镜像仓库地址之一
```
    maven { url 'https://mirrors.cloud.tencent.com/nexus/repository/maven-public/'}
    maven { url 'https://mirrors.163.com/maven/repository/maven-public/'}
```
如果 `react-native start` 出现错误提示 “increase the fs.inotify.max_user_watches sysctl” ，则可按 [Increasing the amount of inotify watchers](https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers) 进行操作。

上面的 `react-native run-android` 实际上执行的命令是 `./android/gradlew installDebug -p ./android/` ，这个命令每次执行时都会尝试从网上下载一些第三方组件的最新版。可以根据自己的实际情况优化这个命令，比如不想每次都尝试网上下载而是离线编译时添加 `--offline` ，就像这个命令 `./android/gradlew installDebug --offline -x lint -x lintVitalRelease -p ./android/` 中做的那样，不过当离线编译出现比如

    Could not resolve com.android.tools.lint:lint-gradle:26.5.3

这样错误时，就需要临时去掉 `--offline` 来运行一次。

如果编译时出现如下错误
```
CMake Error at android/app/build/generated/autolinking/src/main/jni/Android-autolinking.cmake:9 (add_subdirectory):
add_subdirectory given source
"node_modules/@budzworthy/react-native-multi-ble-peripheral/android/build/generated/source/codegen/jni/"
which is not an existing directory.
```
则需要先 `./android/gradlew clean -p ./android/` 。

如果 APP 启动就闪退出现，并且 logcat 中有错误提示 “java.lang.UnsatisfiedLinkError: couldn't find DSO to load: libfbjni.so result: 0” ，则需要 `./android/gradlew assembleDebug --rerun-tasks -p ./android/` 或者是 `./android/gradlew clean -p ./android/; react-native run-android; react-native start --reset-cache` 。

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
```
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
```
### 生成 apk

    cd android
    ./gradlew assembleRelease

如果在此过程中报出 `Out of Memory Error` 的错误，则需要在 `~/.gradle/gradle.properties` 中添加类似如下内容：

    org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8

更多用法参见 [React-Native 离线打包](http://alihub.org/14659907331638.html) 。

### 生成 aab

    ./android/gradlew bundleRelease --offline -x lint -x lintVitalRelease -p ./android/

如果生成好的 aab 在上传到 Google Play 时报错说“您上传的 APK 或 Android App Bundle 内含活动、活动别名、服务或广播接收器，这些项目有 intent 过滤器，但没有“android:exported”属性设置。此文件无法在 Android 12 或更高版本上安装”，且将自己 APP 的 `android:exported` 设为 true 后仍然如此，则将 `compileSdkVersion` 设为 31 再次进行编译时就可以依据 [Apps targeting Android 12 and higher are required to specify an explicit value for android:exported when the corresponding component has an intent filter defined. See https://developer.android.com/guide/topics/manifest/activity-element#exported for details](https://github.com/facebook/react-native/issues/35232#issuecomment-1324619149) 中所说的错误定位到某个第三方组件了。

如果将 `compileSdkVersion` 设为 31 后编译时碰到 `Installed Build Tools revision 31.0.0 is corrupted` 错误，则需要从低版本比如 `android-sdk/build-tools/30.0.0/` 中复制出 `d8` 和 `d8.jar` 来，或是参考 [https://stackoverflow.com/a/68430992/6318705](https://stackoverflow.com/a/68430992/6318705)

    cd ~/tools/android-sdk/build-tools/31.0.0
    mv d8 dx \
    cd lib  \
    mv d8.jar dx.jar

## release 在线更新（热更新）
参见 [React Native CodePush实践小结](https://segmentfault.com/a/1190000009642563) 。

针对后端 API 版本更新问题，在网上搜了一圈罗列在下面，可以发现公说公有理、婆说婆有理，我觉得还不如统一使用最简单的 react-native 前端热更新。
```
对于实在没有办法需要全面升级接口的。如果可能，保持原有的业务、原有的接口运转正常。然后构建一套全新的隔离的接口。最后做下版本使用监控。当观察到所有用户都使用新版本的客户端的时候，并保持一段时间的时候。放弃对老版本的维护，继而下掉老版本的资源。当然，万不得已的时候，还可以用强制更新。
有的公司，每次发布完 APP ，就强制用户更新到最新版本。不推荐这样，因为用户体验太差。
就算是用强制更新，在苹果审核期间，新的 APP 接口和老的接口也必须能同时使用。
一般向下兼容 2 个版本。
如果贵司的 API 是公开的，供第三方开发者使用的话，请一定记着维持兼容性，不然每次升级都大改的话，开发者只会怀疑你们一开始就没设计好，然后就没人用了。这种情况给开发者一个缓冲阶段，让他们在期限前升级到新版本，然后就可以放弃旧版本了。
如果仅供自己使用的话，要求用户强制升级，旧版本直接扔掉就行了。
```

## 安装 react-dom
安装后续要安装的 react-native-web 或 react-web 的 package.json 中的 `peerDependencies` 里的 `react` 和 `react-dom`，因为 react-native-web 或 react-web 相当于是 `react` 和 `react-dom` 这两个宿主的插件，想要装插件就要先装宿主。由于上面 `npx @react-native-community/cli init` 已经自动安装了 react ，所以现在只需安装 react-dom ：

    cd AwesomeProject
    npm install react-dom --save

## RN >= 0.60 的安装 react-native-web
    npm install react-native-web
    npm install react-app-rewired react-error-overlay@6.0.9 --save-dev

(`react-error-overlay@6.0.10` will cause `Uncaught ReferenceError: process is not defined` when hot reloading)

* Create `web/aliases/react-native/index.js`:
```
// ref to https://levelup.gitconnected.com/react-native-typescript-and-react-native-web-an-arduous-but-rewarding-journey-8f46090ca56b

import {Text as RNText, Image as RNImage} from 'react-native-web';
// import RNModal from 'modal-enhanced-react-native-web';
// Let's export everything from react-native-web
export * from 'react-native-web';

// And let's stub out everything that's missing!
export const ViewPropTypes = {
  style: () => {},
};
RNText.propTypes = {
  style: () => {},
};
RNImage.propTypes = {
  style: () => {},
  source: () => {},
};

export const Text = RNText;
export const Image = RNImage;
// export const Modal = RNModal;
// export const ToolbarAndroid = {};
export const requireNativeComponent = () => {};
```

* Create `public/index.html`:
```
<!DOCTYPE html>
<html>
  <head>
    <title>React App</title>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
    <style>
      /* These styles make the body full-height */
      html,
      body {
        height: 100%;
      }
      /* These styles disable body scrolling if you are using <ScrollView> */
      body {
        overflow: hidden;
      }
      /* These styles make the root element full-height */
      #root {
        display: flex;
        height: 100%;
      }
    </style>
  </head>

  <body>
    <div id="root"></div>
  </body>
</html>
```

* Modify `"index"` into `"index.android"` in `android/app/src/main/java/com/yourprojectname/MainApplication.java`

* Modify `@"index"` into `@"index.ios"` in `/ios/YourProjectName/AppDelegate.m`

* Modify
```
    shellScript = "export NODE_BINARY=node\n../node_modules/react-native/scripts/react-native-xcode.sh";
```
into
```
    shellScript = "export NODE_BINARY=node\nexport ENTRY_FILE=index.ios.js\n../node_modules/react-native/scripts/react-native-xcode.sh\n";
```
in `ios/PixelShapeRN.xcodeproj/project.pbxproj`

* Create `index.android.js` and `index.ios.js`:
```
// because index.android.js or index.ios.js can worked in
// react-native-code-push@5.2.0 and bugsnag-react-native@2.5.1,
// but not index.native.js

import {AppRegistry} from 'react-native';
import App from './src/index.js';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
```

### `react-scripts@3`

    npm install react-scripts@3.4.3 babel-jest@24.9.0 eslint@6.6.0 jest@24.9.0 --save-dev

* Create `index.web.js`:
```
import {AppRegistry} from 'react-native';
import App from './src/index.js';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);

AppRegistry.runApplication(appName, {
  rootTag: document.getElementById('root'),
});
```

* Create `config-overrides.js` in your project root:
```
// used by react-app-rewired

const webpack = require('webpack');
const path = require('path');

module.exports = {
  webpack: function (config, env) {
    // To enable the eslint rules in '.eslintrc.js'
    config.module.rules[1].use[0].options.baseConfig.extends = [
      path.resolve('.eslintrc.js'),
    ];

    // To avoid sometimes react-app-rewired is not honouring your change to the eslint rules
    // in '.eslintrc.js', you should manually disable the eslint cache, ref to
    // https://github.com/facebook/create-react-app/issues/9007#issuecomment-628601097
    config.module.rules[1].use[0].options.cache = false;

    // To enable '.eslintignore'
    config.module.rules[1].use[0].options.ignore = true;

    // To let alias like 'react-native/Libraries/Components/StaticRenderer'
    // take effect, must set it before alias 'react-native'
    delete config.resolve.alias['react-native'];
    config.resolve.alias['react-native/Libraries/Components/StaticRenderer'] =
      'react-native-web/dist/vendor/react-native/StaticRenderer';
    config.resolve.alias['react-native'] = path.resolve(
      'web/aliases/react-native',
    );

    // Let's force our code to bundle using the same bundler react native does.
    config.plugins.push(
      new webpack.DefinePlugin({
        __DEV__: env === 'development',
      }),
    );

    // Keep all rules except the eslint - note that if they add additional rules this will need updating to match
    // Consider if this should only apply to the development environment? If so, uncomment the if statement
    // if (env === 'development') {
    //   config.module.rules.splice(1, 1);
    // }

    // Need this rule to prevent `Attempted import error: 'SOME' is not exported from` when `react-app-rewired build`
    // Need this rule to prevent `TypeError: Cannot assign to read only property 'exports' of object` when `react-app-rewired start`
    config.module.rules.push({
      test: /\.(js|tsx?)$/,
      // You can exclude the exclude property if you don't want to keep adding individual node_modules
      // just keep an eye on how it effects your build times, for this example it's negligible
      // exclude: /node_modules[/\\](?!@react-navigation|react-native-gesture-handler|react-native-screens)/,
      use: {
        loader: 'babel-loader',
      },
    });

    return config;
  },
  paths: function (paths, env) {
    paths.appIndexJs = path.resolve('index.web.js');
    paths.appSrc = path.resolve('.');
    paths.moduleFileExtensions.push('ios.js');
    paths.moduleFileExtensions.push('android.js');
    paths.moduleFileExtensions.push('native.js');
    return paths;
  },
};
```

* Add below into `package.json`:
```
  "scripts": {
   "web": "react-app-rewired start",
   "build-web": "react-app-rewired build"
  }
```

* Use `npm run web` for development, then view it at [http://localhost:3000](http://localhost:3000) in web browser
* Use `npm run build-web` to generate files in `build/` for production, and can use `npx http-server@13.0.2 build` to simply test it at [http://127.0.0.1:8080](http://127.0.0.1:8080) in web browser.

If some error like below in shell, then you should refactor those lint `Line`, or enable `config.module.rules.splice(1, 1);` in `config-overrides.js`.
```
Failed to compile
  Line 11:25:   Insert `,`
prettier/prettier
```

And since there is webpack config `loader: 'babel-loader'` here, maybe need add some in `babel.config.js` ref to APP ReactWebNative8Koa [RN 0.63.2 -> 0.70.5: works well on Web](https://github.com/flyskywhy/ReactWebNative8Koa/commit/a87437ad0527edaa4a2f643708938accabb26a8d)

### Upgrade to `react-scripts@5` and Add Web Workers support
At the very first, after upgrade react-scripts from 3 to 5 and related babel upgrade (or modify webpack config?), the most important thing is `rm -fr node_modules/.cache/*` first, otherwise will meet many strange error and can't be solved.

    npm install react-app-rewired@2.2.1 react-scripts@5.0.0 codegen.macro react-refresh@0.11.0 react-error-overlay@6.0.9 --save-dev

(lower version of `react-refresh` comes from `metro-react-native-babel-preset` may cause `Module not found: Error: Cannot find module 'react-refresh'`)

#### Upgrade in `package.json`
```
  "scripts": {
    "web": "PLATFORM_OS=web DISABLE_ESLINT_PLUGIN=true react-app-rewired start",
    "web-fresh": "rm -fr node_modules/.cache/*; PLATFORM_OS=web DISABLE_ESLINT_PLUGIN=true react-app-rewired start",
    "build-web": "PLATFORM_OS=web DISABLE_ESLINT_PLUGIN=true react-app-rewired build",
    "build-web-PixelShapeRN": "PUBLIC_URL=/PixelShapeRN PLATFORM_OS=web DISABLE_ESLINT_PLUGIN=true react-app-rewired build"
  }
```

* Use `npm run web` for development, then view it at [http://localhost:3000](http://localhost:3000) in web browser.
* Use `npm run web-fresh` for development to automatically `rm -fr node_modules/.cache/*` first.
* Use `npm run build-web` to generate files in `build/` for production, and can use `npx http-server@13.0.2 build` to simply test it at [http://127.0.0.1:8080](http://127.0.0.1:8080) in web browser.

`PUBLIC_URL=/PixelShapeRN` here is to [fix `build-web-PixelShapeRN` `GET https://flyskywhy.github.io/PixelShapeRN/PixelShapeRN/static/js/main.b043a6c7.js net::ERR_ABORTED 404`](https://github.com/flyskywhy/PixelShapeRN/commit/6f5ce184c8d5cfbaee596a3ec8169bfd3c4828fb), you should replace `PixelShapeRN` here with your github repo name.

`DISABLE_ESLINT_PLUGIN=true` here is to avoid [Failed to load plugin 'flowtype' declared in 'package.json » eslint-config-react-app': Cannot find module 'eslint/use-at-your-own-risk'](https://stackoverflow.com/questions/70397587/failed-to-load-plugin-flowtype-declared-in-package-json-eslint-config-react).

`PLATFORM_OS=web` here work with codegen.macro is to avoid `SyntaxError: import.meta is only valid inside modules.` with react-native, ref to "import.meta.url" in `https://github.com/flyskywhy/PixelShapeRN/blob/v1.1.27/src/workers/workerPool.js`

If not define `DISABLE_ESLINT_PLUGIN=true` , and nodejs version < 14 , will cause `ERROR in Error: Child compilation failed: Module.createRequire is not a function` . If define `DISABLE_ESLINT_PLUGIN=true` , then nodejs version can < 14 because only `eslint@8` is using `Module.createRequire` .

#### Upgrade in `config-overrides.js` `index.web.js` and other files
Ref to APP ReactWebNative8Koa [RN 0.63.2 -> 0.70.5: let Web Worker with Support for CRA v5 (and Webpack 5)](https://github.com/flyskywhy/ReactWebNative8Koa/commit/8adc7bbf43d225b790de88a177aa438ccea8dabc) , and your project may need `npm run stream-browserify process --save-dev` as described in [config-overrides.js](https://github.com/flyskywhy/ReactWebNative8Koa/blob/8adc7bbf43d225b790de88a177aa438ccea8dabc/config-overrides.js#L25).

### Q&A
#### `Unexpected token '<'`
If the url in web browser is `http://localhost:3000/Foo/Bar` not `http://localhost:3000`, and
`Uncaught SyntaxError: Unexpected token '<'` in shell, then you need remove homepage in `package.json` like:
```
  "homepage": "https://github.com/Foo/Bar#readme",
```

#### `npm ERR! ERESOLVE unable to resolve dependency tree`
Ref to [npm installation version problem](https://github.com/flyskywhy/react-native-usb-serialport/issues/2) , you need use npm version which is below 7, or e.g.

    npm install react-native-usb-serialport --legacy-peer-deps

#### `FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory`
If `npm run build-web` got this error, then need change

    "build-web": "react-app-rewired build",

to

    "build-web": "node --max_old_space_size=4096 node_modules/.bin/react-app-rewired build",

#### `Module not found: Error: Can't resolve 'react-native/package.json'`
If using `react-native-gesture-handler@2` not `react-native-gesture-handler@1` will meet `ERROR in ./node_modules/react-native-gesture-handler/lib/module/utils.js 1:0-45` , then need add
```
    config.resolve.alias['react-native/package.json'] = path.resolve(
      'node_modules/react-native/package.json',
    );
```
into `config-overrides.js` .

### `Cannot find module 'ajv/dist/compile/codegen'`
Need
```
npm install ajv@8.17.1
```

#### `Uncaught Error: Cannot find module 'react-native-playtorch'`
It maybe `Uncaught Error: PlayTorchJSIModule not found` if `APP/tsconfig.json` exist.

Fix it by:
```
-import {Camera, Canvas} from 'react-native-playtorch';
+if (Platform.OS !== 'web') {
+  var {Camera, Canvas} = require('react-native-playtorch');
+}
```

#### warning `Module not found: Error: Can't resolve 'react-native-pytorch-core'`
If use a pure ts package e.g. `"react-native-pytorch-core": "git+https://github.com/flyskywhy/playtorch#CameraModule"` which only has `src/` but no `lib/`, then need `npm install @tsconfig/react-native@2.0.2` and create `APP/tsconfig.json` with the content
```
{
  "extends": "@tsconfig/react-native/tsconfig.json"
}
```
thus `const useTypeScript = fs.existsSync(paths.appTsConfig)` in `node_modules/react-scripts/config/webpack.config.js` can be `true`, and patch by

    sed -i -e "s/lib\/commonjs/src/" node_modules/react-native-pytorch-core/package.json

PS: There is already `"react-native": "src/index"` in `react-native-pytorch-core/package.json`, so metro of react native already works fine without the patch.

## RN < 0.60 的安装 react-web
    npm install -g react-web-cli

在项目根目录的上层目录中创建 react-web 项目

    cd ..
    react-web init AwesomeProject

因官方 react-web 已停止维护，所以接下来可使用我维护的仓库替代

    cd AwesomeProject
    npm uninstall react-web
    npm install https://github.com/flyskywhy/react-web.git#f6c63e3

在项目根目录中运行如下命令即可启动 webpack 调试服务器，然后在浏览器打开 localhost:3000 即可：

    react-web start

坑：有时修改了 js 文件但是 webpack 调试服务器没有自动重新 bundle ，这个 BUG 可以通过重启电脑解决。

其它可参见 [三步将 React Native 项目运行在 Web 浏览器上面](http://taobaofed.org/blog/2016/03/11/react-web-intro/)

在项目根目录中运行如下命令即可打包 Web 到 `web/output/` 目录中

    react-web bundle

## 配置 iOS 开发环境
除了为 React Native [搭建开发环境](https://reactnative.cn/docs/environment-setup.html) ，还需 [像 Mac 高手一样管理应用，从 Homebrew 开始](https://sspai.com/post/42924) 使用 `brew install` 或 `mas install` 安装各种实用工具。安装过程中最好保持翻墙状态，否则速度较慢或无法安装。另可参考 [我在 Mac 上都用什么](https://www.cnblogs.com/imzhizi/p/my-apps-on-mac.html) 以及 [macOS使用详解](../../../Os/macOS/macOS使用详解.md) 。

    brew install mas node watchman dos2unix mosh
    brew install sublime-text double-commander google-chrome the-unarchiver iterm2 xquartz typora meld intelliscape-caffeine bitbar geektool turbovnc-viewer microsoft-remote-desktop flux inkscape gimp

注：其中 `turbovnc-viewer` 的运行需要先安装下面提到的 JAVA 环境，并在 macOS 自带终端中运行(在 iterm2 中运行没有效果)如下语句：

    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
    launchctl setenv JAVA_HOME $JAVA_HOME

* 升级 node 的方法

可以采用如下方法升级到比如 v16 版本：

    brew install node@16

然后在 `~/.zshrc` 或 `~/.bash_profile` 中添加如下语句并重启电脑：

    export PATH=/usr/local/opt/node@16/bin:$PATH

最后在运行比如 `react-native start` 之前开发者有时想要运行的 `watchman watch-del-all` 过程中出现类似

    dyld[23087]:  Library not loaded: /usr/local/opt/icu4c/lib/libicudata.71.dylib
      Referenced from: /usr/local/Cellar/boost/1.79.0_2/lib/libboost_regex-mt.dylib
    sh: line 1: 23087 Abort trap: 6           watchman watch-del-all

这样的报错，则需要：

    brew upgrade

来自动升级 boost 到最新版。

另，在 Xcode 打包 release 时会调用 `/usr/local/bin/node` ，所以还需要：

    ln -sf $(which node) /usr/local/bin/node

* 解决 `brew install` 或 `npm install -g` 时出现的 `/usr/local/` 权限问题

如果当前不是 macOS 的第一个用户，就算已加入 admin 组，也还需要手动加入 wheel 组：

    sudo dseditgroup -o edit -a $USER -t user wheel

* 解决 `brew install` 卡住很久的问题

brew 在安装软件前会先尝试升级 brew 自身，这里可能是中国网络环境的原因而会卡住很久，如果不想要升级 brew 自身的，此时可以直接 `CTRL + C` 跳过，它就会自动继续去安装了。

* 解决 `brew install` 的 git-gui 运行时容易崩溃或是 gitk 无法调出鼠标右键菜单的问题

使用其它 git 的图形化客户端替代，比如

    brew install fork

* 解决 `brew install` 时出现的 `Error: Your CLT does not support macOS 11.2.` 问题

该错误一般是因为 macOS 升级了但 Xcode 的 `Command Line Tools` 还没有匹配更新。该错误有时也会表现为 `Error: Your Xcode does not support macOS 11.2.` 的形式。解决方法为：

    sudo rm -rf /Library/Developer/CommandLineTools
    sudo xcode-select --install

如果错误依旧，则：

    sudo rm -rf /Library/Developer/CommandLineTools

之后，再去 https://developer.apple.com/download/more/ 下载安装最新的 `Command Line Tools` 。

* 安装 JAVA 环境

如果想在 macOS 上编译 Android APP ，则还需参考 [https://reactnative.dev/docs/0.70/environment-setup?guide=native&os=macos](https://reactnative.dev/docs/0.70/environment-setup?guide=native&os=macos) 一文安装 JDK11

    brew install --cask zulu@11

如果编译 Android NDK 过程中出现如下错误的
```
> Task :libuvccamera:ndkBuild FAILED
Android NDK: Host 'awk' tool is outdated. Please define NDK_HOST_AWK to point to Gawk or Nawk !
```
则需要在`~/.zshrc`中添加
```
export NDK_HOST_AWK=/usr/bin/awk
```

## Xcode 编译过程问题集锦

* `Signing for "React-Core-AccessibilityResources" requires a development team`

Xcdoe 14 会遇到这个错误，解决方法是在 Xcode 左边的 `Project navigator` 中点击 `Pods`，然后点击此时出现在右边的 `Signing & Capabilities` 并在 `Team` 下拉框中选择一个。

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

* `no template named function in namespace std`

Xcode 16 可能会出现这个问题，解决方法是在`工程文件 | Build Settings (All) | Apple Clang - Language -  C++ | C++ Language Dialect`中选择`C++11[-std=c++11]`。

* 尽量在 Xcode 中编辑文件内容

否则 Xcode 会不知道文件已经编辑过了。如果是在 Xcode 中编辑的话， Xcode 会自动 index 一下，然后 build 时就不会出错了。再次吐槽的是， index 和 build 的速度也太慢了。

* Timeout waiting for modules to be invalidated

曾经在模拟器中安装调试运行时碰到过这个错误，按 https://stackoverflow.com/questions/46206867/timeout-waiting-for-modules-to-be-invalidated 中的说法是需要将真机的 WiFi 连到与 macOS 同一个局域网中，不过我的情况是将模拟器换成真机后就好了，搞不懂背后真正的原因是啥。

注：参考 [How to share your Mac's internet with iPhone, iPad, Android, etc](https://www.idownloadblog.com/2022/12/01/how-to-share-mac-wi-fi-internet/) 一文将上网能力通过 macOS 的 USB 口分享给 iPhone ，由于是有线连接，所以 Hot reloading 的速度快到飞起。

* 真机调试时需要在 Xcode 的菜单 `Preferences | Accounts` 那里添加 Apple ID ，并在 Xcode 的主界面中的 Project 的某个 Target 的 'Signing & Capabilities' 那里选择相应的 Team 。

但是，千万要记得所添加的那个 Apple ID 就是今后将要用来发布到 App Store 的账号，否则如果先用自己个人的免费账号在真机上进行调试了，那么苹果服务器就会自动将你所调试的 APP 的 PRODUCT_BUNDLE_IDENTIFIER 比如 com.domainname.appname 作为 APP ID 保存到你的个人账号名下了，那样等你后续用公司的收费账号在 https://developer.apple.com/ 上申请 Identifiers 时，它就会说 "An App ID with Identifier 'com.domainname.appname' is not available" ，而你用免费账号登录 https://developer.apple.com/ 的话根本连 Identifiers 的进入按钮都看不见更别说删除该 APP ID 了，这样你只能让你的公司账号下的 PRODUCT_BUNDLE_IDENTIFIER 改名……苹果公司又一个反人类的设计。

第一次打包 APP 以便在真机上运行时， Xcode 会弹出对话框让你输入苹果电脑登录密码以便访问钥匙串，你确定一次后，又回弹出一次，再确定，再弹出，次数多到让你以为你输错了苹果电脑登录密码……一共会弹出 10 次左右的对话框……

* 添加 Apple ID 时报错说“未知错误”

如果局域网不太稳定（比如路由器再加一个 WiFi 放大器）就容易出现这个问题，可以通过临时连接手机热点来简单解决之。

* 开发时也需要连接苹果公司服务器

在 Xcode 中点击 Run 按钮第一次将 APP 在真机上运行时，当真机界面上出现 APP 图标时， Xcode 会弹出对话框，按照其提示到真机的 `设置 | 通用 | 设备管理 | 开发者 APP` 中进行验证，然而接着关闭 Xcode 中的对话框后， Xcode 并不会接着继续启动 APP 进行调试，如果你想在 Xcode 中看到调试信息的话，你就不得不再次点击 Run 按钮自动 build 安装共 3 分钟后才行，真是浪费生命。而更吊诡的是，如果后续某个时间你的路由器因某种原因与互联网连接断开，那么连接在路由器的 WiFi 上的真机中的 APP 又变成了需要验证的状态，也就是你没有互联网的话就连代码调试都无法做到，苹果公司的服务器时刻在看着你……

* 用 Debug 配置进行调试

由于使用 Release 配置点击 Run 按钮的话需要等待半小时，所以调试时记得将 `Produce | Scheme | Edit Scheme | Run | Build Configuration` 设置为 Debug 。其实就算使用 Debug ，运行也需要 3 分钟，哪像 react-native 开发时只需要手机摇一摇花 3 秒钟就能看到 JS 代码所做的改变。真为那些全部代码都使用 Xcode 原生编写的开发人员感到悲哀——每天不知道浪费了多少个 3 分钟。还好我只需要捏着鼻子偶尔用连语法都是反人类的 ObjectC 语言在 Xcode 中做一些原生适配，就又可以愉快地去写 JS 代码了。

注： [https://reactnative.dev/docs/publishing-to-app-store](https://reactnative.dev/docs/publishing-to-app-store) 提到 `export SKIP_BUNDLING=true` 可以进一步减少 Debug 编译运行的时间。

* 项目所在绝对路径中不应该有空格，否则编译会失败

* 配置 node 路径

如果没有标准化安装 nodejs ，比如 `brew install node@10` 这种方式安装的，则就算已经在 `~/.zshrc` 或 `~/.bash_profile` 中 `export PATH=/usr/local/opt/node@10/bin:$PATH` 了，也还是会在真机编译时报 `Can't find 'node' binary to build React Native bundle` 这样的错误，此时需要按提示到 Xcode 的 Project 的 `Build Phases | Bundle React Native code and images` 那里将 `export NODE_BINARY=node` 改为 `export NODE_BINARY=$(which node)` 。或者还有一种方法 `ln -s $(which node) /usr/local/bin/node` 。

* `EMFILE: too many open files`

如果即使[macOS 开启或关闭 SIP](https://sspai.com/post/55066)关闭 SIP 然后`launchctl limit maxfiles 16384 16384 && ulimit -n 16384`了也没用，那是因为对于 M2 的苹果电脑，需要做的是参考 [https://github.com/facebook/watchman/issues/923#issuecomment-2550990976](https://github.com/facebook/watchman/issues/923#issuecomment-2550990976) 中那样在`TARGETS > (your app) > Build Phases > Bundle React Native code and images`中将`/opt/homebrew/bin`添加到`$PATH`中。另外，还需在编译前手动执行一次`watchman watch-del-all`。

* `ld: 5 uplicate symbols`

将 XCode 升级到 15 之后，比如编译使用着`telink sdk v3.3.3.5`的`react-native-btsig-telink@5.0.3`时，在链接阶段报了该错误，以其中一个为例
```
duplicate symbol '_OBJC_IVAR_$_SigECCEncryptHelper._crypto'
```
解决方法是在 Xcode 的 Project 的`Build Settings(All) | Linking | Other Linker Flags`内添加 `-ld_classic`。

* release error with [data-uri.macro](https://github.com/Andarist/data-uri.macro)

如果 APP 中使用了 `data-uri.macro` ，则 release 打包时会出现比如 `Error: /Users/YOU/proj/YOUR_APP/ios/app/images/gif/index.js: data-uri.macro: ENOENT: no such file or directory, open '/Users/YOU/proj/YOUR_APP/ios/app/images/gif/spot.gif'` ，此时需要到 Xcode 的 Project 的 `Build Phases | Bundle React Native code and images` 那里将

    ../node_modules/react-native/scripts/react-native-xcode.sh

改为

    cd ..
    ./node_modules/react-native/scripts/react-native-xcode.sh

* 为 Xcode 添加 iOS-DeviceSupport

如果真机调试运行时出现比如 `This iPhone 7 (Model 1660, 1778, 1779, 1780) is running iOS 13.2.3 (17B111), which may not be supported by this version of Xcode. An updated version of Xcode may be found on the App Store or at developer.apple.com.` 这样的错误提示，它的意思是当前版本的 Xcode 不支持真机上的 iOS 操作系统版本。调试一个手机 APP 还必须要 IDE 支持手机操作系统的版本，这样的反人类设计恐怕也只有苹果公司才做得出来。可以如提示中所说升级 Xcode 自身，但 Xcode 安装包要 7 个多 GB ，而且偶尔某个版本的 Xcode 会出现一些奇奇怪怪的 BUG ，所以最简洁的方式其实是为当前版本的 Xcode 的安装目录某个地方多添加一个比如 13.2 目录即可。

从 https://github.com/iGhibli/iOS-DeviceSupport/tree/master/DeviceSupport 下载比如 `13.2(FromXcode11.2.1(11B500)).zip` ，解压出 `13.2` 目录， `sudo mv 13.2 /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/` ，最后重启 Xcode 并重连手机即可。

* `dyld: Library not loaded: /usr/local/opt/icu4c/lib/libicui18n.66.dylib`

如果在 Xcode 持续开启的状态下，比如为了满足 App Store 上预览视频的分辨率要求而在终端里 `brew install ffmpeg` 用于视频转码，然后一转眼 Xcode 运行 `Product | Archive` 打包到 node 步骤时即可能报上述错误，其原因是 node 和 ffmpeg 都依赖 icu4u ，而一般情况下 node 是比较早之前安装的，那时候自动安装的 icu4u 版本如果比现在 ffmpeg 触发安装的 icu4u 版本旧的话，就会出现本问题。解决的方法是重新启动 Xcode 。

* Could not build module 'Darwin'

如果升级了 RN 版本后再次编译，可能会碰到这个错误，此时只要
```
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
rm -rf ~/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex
rm -rf ~/Library/Developer/Xcode/DerivedData/SymbolCache.noindex
cd ios
pod install
````
即可。

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

注：许多网页介绍的清华镜像下载速度很慢甚至无法下载完成，所以推荐将下面语句中的 `https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git` 替换为 `https://gitee.com/mirrors/CocoaPods-Specs.git` 。如果你能下载大型的 github 仓库而不中途被断掉的话（比如通过 `git config --global http.proxy 你的代理服务器` 的方式），则推荐替换为更加实时更新的 `https://github.com/CocoaPods/Specs.git` 。

    cd ~/.cocoapods/repos
    pod repo remove master
    git clone --depth 1 https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git master

后续如果 `pod install` 时出现 `CocoaPods could not find compatible versions for pod` 的错误而想要更新，只需

    cd ~/.cocoapods/repos/master
    git pull

即可。最后进入自己的工程，在自己工程的 Podfile 第一行加上：

    source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

或是让 Podfile 中保持 `https://github.com/CocoaPods/Specs.git` 并且将 `~/.cocoapods/repos/master/.git/config` 中的 `https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git` 替换为 `https://github.com/CocoaPods/Specs.git` ，则也是可以的。

然后就可以正常 `pod install` 了（第一次可能需要删除已经存在的 Podfile.lock 文件）。

另外，有时候比如 `git reset` 到某个提交点后做 `pod install` 时出现

    NoMethodError - undefined method `each' for nil:NilClass

的错误，这一般也是需要删除 Podfile.lock 文件。

如果 `pod install` 时卡死在某个 `Installing` 上，或者最终它报出来 `LibreSSL SSL_connect: Operation timed out in connectiong to github.com:443`，则可以参照[pod install/update 卡住](https://blog.csdn.net/u011374880/article/details/106327526)一文里的解决方法，或是在 `~/.gitconfig` 中添加
```
    [http "https://github.com/"]
        proxy = http://你的科学上网代理IP:端口
```
如果 `pod install` 时出现比如 `[!] `OpenSSL-Universal` requires CocoaPods version `>= 1.9`, which is not satisfied by your current version, `1.8.4`.` 这样的错误，则先需要

    sudo gem install cocoapods -v 1.9.0

但如果此时出现比如
```
Fetching: ffi-1.15.0.gem (100%)
Building native extensions.  This could take a while...
ERROR:  Error installing cocoapods:
  ERROR: Failed to build gem native extension.

    current directory: /Library/Ruby/Gems/2.3.0/gems/ffi-1.15.0/ext/ffi_c
/System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/bin/ruby -r ./siteconf20210308-55404-19a0g74.rb extconf.rb
mkmf.rb can't find header files for ruby at /System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/lib/ruby/include/ruby.h

extconf failed, exit code 1

Gem files will remain installed in /Library/Ruby/Gems/2.3.0/gems/ffi-1.15.0 for inspection.
Results logged to /Library/Ruby/Gems/2.3.0/extensions/universal-darwin-18/2.3.0/ffi-1.15.0/gem_make.out
```
这样的错误，则先需要比如

    open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg

但如果此时出现找不到这个 `.pkg` 文件的错误，则先需要

    xcode-select --install

但如果此时出现

    xcode-select: error: command line tools are already installed, use "Software Update" to install updates

这样的错误，则先需要

    rm -rf /Library/Developer/CommandLineTools

如果 `pod install` 时出现比如 `Could not find 'minitest'` 这样的错误，则需要
```
unset GEM_HOME
unset GEM_PATH
unset MY_RUBY_HOME
unset RUBY
unset IRBRC
```

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

### Isolating Redux Sub-Apps
Want render a react-native APP as a sub-app (library) in other APP? I implement this requirement in [let other react-native APP can embed PixelShapeRN as sub-app](https://github.com/flyskywhy/PixelShapeRN/commit/9728e45ffe4a5046d7cd8076b2b103c5eef079c5), which ref to [Isolating Redux Sub-Apps](https://redux.js.org/usage/isolating-redux-sub-apps) and [Breaking out of Redux paradigm to isolate apps](https://gist.github.com/gaearon/eeee2f619620ab7b55673a4ee2bf8400)

## react-native-unistyles 3
使用了 RN 新架构的 `react-native-unistyles@3.x` 可以避免 re-render 。

如果在 FlatList 的 ref 中使用了古老的比如 `ref={view => this.flatListRef = view}` 写法，会 `forwardedRefReturnFn is not a function (it is Object)` 导致崩溃，应该使用 `flatListRef = React.createRef(); ... ref={this.flatListRef}` 或 `const flatListRef = useRef(null); ... ref={flatListRef}` 的写法。还有一种方法是使用 `@shopify/flash-list` 替代（至少是 RN 0.79.7 版本的） `FlatList` 。

上述崩溃与是否 `import {StyleSheet} from 'react-native-unistyles'` 了无关，只与该 js 文件是否位于 [Babel plugin _ react-native-unistyles](https://www.unistyl.es/v3/other/babel-plugin) 内所述 root 选项之内有关。

另外，如果不 `import {StyleSheet} from 'react-native-unistyles'` ，则 `StyleSheet.create((theme, rt) => {console.log(rt); return {};});` 没有任何打印输出。

所以，除了按照 [Configuration _ react-native-unistyles](https://www.unistyl.es/v3/start/configuration) 在 `index.js` 中进行 `StyleSheet.configure({})` 以及设置好 `babel.config.js` 之外，还需 `import {StyleSheet} from 'react-native-unistyles'` 才行。

## react-native-unimodules
注：最新版 RN 已经被上面提到的 `npx install-expo-modules` 替代。

react-native 兴起之初，各种第三方组件百家争鸣，但也良莠不齐。最近看来 react-native-unimodules 渐有一统之势，它支持许多开发 APP 时用得到的方方面面的 [Packages](https://docs.expo.io/versions/latest/bare/unimodules-full-list/) ，而且其中所谓 bare workflow 也就是不需要和 Expo 绑定的独立 Packages 已经足够多了。

如果是在 iOS 中使用 react-native-unimodules ，则必须要使用上面提到的 `pod install` 才能正常运行。

### install react-native-unimodules without install expo
The worked well version is

    "react-native-unimodules": "0.10.1",

and related

    "expo-application": "2.4.1",
    "expo-document-picker": "8.3.0",
    "expo-gl": "8.4.0",
    "expo-keep-awake": "8.0.0",
    "expo-location": "10.0.0",

The installation of `react-native-unimodules` can ref to this commit [expo -> react-native: add react-native-unimodules](https://github.com/flyskywhy/snakeRN/commit/90983816de3ad2a4da47ffa0f6d1659c2688be3e), and if RN >= 0.65 , to compile react-native-unimodules, need downgrade to gradle-6.7.1-all.zip in `YOUR_APP/android/gradle/wrapper/gradle-wrapper.properties` , and because `invalidate` replaces `onCatalystInstanceDestroy` in RN >= 0.65, ref to [https://github.com/facebook/react-native/commit/18c8417290823e67e211bde241ae9dde27b72f17](https://github.com/facebook/react-native/commit/18c8417290823e67e211bde241ae9dde27b72f17), you need

    sed -i -e "s/^}$/public void invalidate() {}}/" node_modules/@unimodules/react-native-adapter/android/src/main/java/org/unimodules/adapters/react/services/CookieManagerModule.java

## 一些 BUG 的解决方法
### [fixed `TypeError: Network request failed` when upload file to http not https with Android debug builds](https://github.com/facebook/react-native/issues/33217#issuecomment-1159844475)

### Fixed [x/mobile: Calling net.InterfaceAddrs() fails on Android SDK 30](https://github.com/golang/go/issues/40569#issuecomment-1190950966) if use GO on Android >= 11

### `$rootDir/../node_modules/react-native/android` as [React-Native Android import from node_modules directory does not working](https://stackoverflow.com/questions/50354939/react-native-android-import-from-node-modules-directory-does-not-working)
The 2022-11 issue [No matching variant of com.facebook.react:react-native:0.71.0-rc.0 was found.](https://github.com/facebook/react-native/issues/35210) will cause one of Android build/run failures below:
```
AAPT: error: resource android:attr/lStar not found
```
```
java.lang.IncompatibleClassChangeError: Found class com.facebook.react.uimanager.events.EventDispatcher, but interface was expected
```
```
Manifest merger failed : uses-sdk:minSdkVersion 16 cannot be smaller than version 21 declared in library [com.facebook.react:react-native:0.71.0-rc.0] ~/.gradle/caches/transforms-2/files-2.1/b7e5811cc2418a7984972c8ebe02d2c4/jetified-react-native-0.71.0-rc.0-debug/AndroidManifest.xml as the library might be using APIs not available in 16
```
```
Could not download react-native-0.71.0-rc.0-debug.aar (com.facebook.react:react-native:0.71.0-rc.0): No cached version available for offline mode
```
```
/@minar-kotonoha/react-native-threads/android/src/main/java/com/reactlibrary/ReactContextBuilder.java:15: 错误: 找不到符号
import com.facebook.react.bridge.NativeModuleCallExceptionHandler;
```
Then fix below in `android/app/build.gradle` does not working anymore:
```
implementation ("com.facebook.react:react-native:0.63.2") { force = true }
```
```
implementation "com.facebook.react:react-native:0.63.2!!"
```
```
android {
    ....
    configurations.all {
        resolutionStrategy {
            // failOnVersionConflict()
            // force 'com.facebook.react:react-native:0.63.2'
            substitude module('com.facebook.react:react-native:+') with module('com.facebook.react:react-native:0.63.2')
        }
    }
}
```
```
android {
    ....
    configurations.all {
          resolutionStrategy.eachDependency { DependencyResolveDetails details ->
            if (details.requested.group == 'com.facebook.react'
                && details.requested.name == 'react-native') {
                details.useVersion "0.63.2"
                // details.useTarget group:'com.facebook.react', name:'react-native', version:"0.63.2"
                // it.substitute it.module("com.facebook.react:react-native:+") with module("com.facebook.react:react-native:0.63.2")
            }
        }
    }
}
```
Finally fix below in `android/build.gradle`  can work ref to https://github.com/facebook/react-native/issues/35204#issuecomment-1304740228 :
```
    allprojects {
        repositories {
            exclusiveContent {
                filter {
                    includeGroup "com.facebook.react"
                }
                forRepository {
                    maven {
                        url "$rootDir/../node_modules/react-native/android"
                    }
                }
            }
        }
        ...
        // actually now can remove below lines
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url("$rootDir/../node_modules/react-native/android")
        }
    }
```
### Recompile with -Xlint:deprecation for details
If got an error like below:
```
Note: ... SOME.java uses or overrides a deprecated API
Note: Recompile with -Xlint:deprecation for details.

FAILURE: Build failed with an exception.

* Where:
Script 'YOUR_APP/node_modules/react-native/react.gradle' line: 319

* What went wrong:
Execution failed for task ':app:packageDebug'.
> react_80jkne8u4hv8b3lwi0xrttidv$_run_closure4$_closure6$_closure10$_closure18
```
Then you need remove `~/.gradle/caches/`, if some file in it can't be removed for "file is in use" on Windows, you should restart Windows and remove it again. Ref to https://github.com/facebook/react-native/issues/28665#issuecomment-826251902 .

### Compile some 3rd lib got `Read timed out` `Could not GET 'https://maven.google.com/com/facebook/react/react-native/maven-metadata.xml'`
Ref to [RN 0.63.2 -> 0.70.5: fix Read timed out when compiling on Android](https://github.com/flyskywhy/ReactWebNative8Koa/commit/96fad3d9524e64fa309d0e72a4d9ad4808a1470f) , need add below into `settings.gradle`:
```
// ref to https://docs.gradle.org/7.5.1/userguide/declaring_repositories.html#sub:centralized-repository-declaration
dependencyResolutionManagement {
    // to fix `Read timed out` e.g.
    //    > Could not resolve com.facebook.react:react-native:0.70.+.
    //       > Failed to list versions for com.facebook.react:react-native.
    //          > Unable to load Maven meta-data from https://maven.google.com/com/facebook/react/react-native/maven-metadata.xml.
    //             > Could not GET 'https://maven.google.com/com/facebook/react/react-native/maven-metadata.xml'.
    //                > Read timed out
    //    > Could not download bcprov-jdk15on-1.48.jar (org.bouncycastle:bcprov-jdk15on:1.48)
    //       > Could not get resource 'https://repo.maven.apache.org/maven2/org/bouncycastle/bcprov-jdk15on/1.48/bcprov-jdk15on-1.48.jar'.
    //          > Read timed out
    //    > Could not download guava-17.0.jar (com.google.guava:guava:17.0)
    //       > Could not get resource 'https://repo.maven.apache.org/maven2/com/google/guava/guava/17.0/guava-17.0.jar'.
    //          > Read timed out
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        maven { url 'https://mirrors.cloud.tencent.com/nexus/repository/maven-public/'}
        maven { url 'https://mirrors.163.com/maven/repository/maven-public/'}
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'https://maven.aliyun.com/repository/central' }
        // maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/nexus/content/groups/public' }

        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url("$rootDir/../node_modules/react-native/android")
        }
        maven {
            // Android JSC is installed from npm
            url("$rootDir/../node_modules/jsc-android/dist")
        }
        mavenCentral {
            // We don't want to fetch react-native from Maven Central as there are
            // older versions over there.
            content {
                excludeGroup "com.facebook.react"
            }
        }
        google()
        maven { url 'https://www.jitpack.io' }
    }
}
```
and also remove useless `allprojects` in `build.gradle`.

Now after `./android/gradlew clean -p ./android/`, you can continue your build.

### `AAPT: error: resource android:attr/colorError not found`
If got error like
```
> A failure occurred while executing com.android.build.gradle.tasks.VerifyLibraryResourcesTask$Action
   > Android resource linking failed
     ERROR: node_modules/@flyskywhy/react-native-locale-detector/android/build/intermediates/merged_res/release/values-v26/values-v26.xml:7: AAPT: error: resource android:attr/colorError not found.
```
you may need add below into `YOUR_APP/android/build.gradle`:
```
subprojects {
    afterEvaluate {
        project ->
            if (project.hasProperty("android")) {
                android {
                    compileSdkVersion = rootProject.compileSdkVersion
                    buildToolsVersion = rootProject.buildToolsVersion
                }
            }
    }
}
```

### `Could not resolve org.webkit:android-jsc:+`
Downgrade gradle-6.7-all.zip (comes from RN 0.64.3) to gradle-6.2-all.zip (comes from RN 0.63.2) in `android/gradle/wrapper/gradle-wrapper.properties` to fix it, ref to [https://stackoverflow.com/a/76521192/6318705](https://stackoverflow.com/a/76521192/6318705)

### [专治各种网络不服](https://incoder.org/2020/02/27/fuck-gfw/)
