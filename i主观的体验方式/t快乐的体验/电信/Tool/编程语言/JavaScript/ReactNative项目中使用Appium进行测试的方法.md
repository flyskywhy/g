Li Zheng <flyskywhy@gmail.com>


## 基本架构

* 测试用例代码调用测试客户端比如 [CodeceptJS](https://github.com/Codeception/CodeceptJS)
* 测试客户端调用测试服务端比如 [Appium](https://github.com/appium/appium) 或 [Selenium](https://github.com/SeleniumHQ/selenium)
* 测试服务端连接 Android 、 iOS 或 Web 以运行 RN 程序

## 环境搭建
    npm install --save-dev webdriver-manager codeceptjs webdriverio mocha

参考 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 的 package.json ，在 scripts 一节中添加如下内容：

    "e2e-update-server-web": "webdriver-manager update --versions.standalone=3.7.1 --versions.gecko=v0.18.0",
    "e2e-server-web": "touch node_modules/webdriver-manager/selenium/standalone-response.xml; touch node_modules/webdriver-manager/selenium/chrome-response.xml; webdriver-manager start --versions.standalone=3.7.1 --versions.gecko=v0.18.0",
    "e2e-web": "codeceptjs run",
    "e2e-server-native": "appium",
    "e2e-android": "codeceptjs run --profile=android",
    "e2e-ios": "codeceptjs run --profile=ios"

在 package.json 的 devEngines 一节中添加如下内容：

    "node": ">= 6.11.1"

运行如下命令以安装 Appium

    npm install -g appium

如果因为在中国而无法完成这个命令，可考虑 `git clone https://github.com/flyskywhy/node_modules-appium` ，然后把 clone 下来的 `node_modules-appium/` 移动到 node 安装目录成为 `lib/node_modules/appium/` ，再进入 node 安装目录的 `bin` 中运行 `ln -s ../lib/node_modules/appium/build/lib/main.js appium` 。

运行如下命令以安装 Selenium

    npm run e2e-update-server-web

使用 [CodeceptJS 命令行自动生成示例文件](http://codecept.io/commands/) ，了解 CodeceptJS 所需的测试用例代码的文件结构，然后参考 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 完善自己所需的测试用例代码的文件内容，还可参考更复杂的 [https://github.com/faikfaisal/Centricity-Automation](https://github.com/faikfaisal/Centricity-Automation) 以及 [https://github.com/flyskywhy/codeceptjs4game](https://github.com/flyskywhy/codeceptjs4game) 。

使用比如 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 中的 `codecept.conf.js` 配置文件，配合上面的 `package.json` 就可以很容易地切换 Android 、 iOS 和 Web 分别进行测试。

### Android

从 https://developer.android.google.cn 下载 sdk-tools-linux 成为比如

    ~/tools/android-sdk/

在 ~/.bashrc 中添加

    export ANDROID_HOME=~/tools/android-sdk
    PATH=~/tools/android-sdk/platform-tools:~/tools/android-sdk/tools:$PATH

安装 Appium 运行时所需的 Android SDK 的包 ：

    ~/tools/android-sdk/tools/bin/sdkmanager platform-tools
    ~/tools/android-sdk/tools/bin/sdkmanager "build-tools;26.0.1"

### 图形界面
除了命令行方式，也可以看看 Appium 的 desktop application 图形界面的方式是否足够适用，详见 https://github.com/appium/appium-desktop （Windows 版的 Appium 图形界面程序可以在 https://github.com/appium/appium-desktop/releases 下载）。

## 本地测试
### Android
1、用比如 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 的 package.json 中的 `npm run android` 编译出 apk 并连接 Android 真机或启动 Android 模拟器，以及视情况而定的 `npm start` ；

2、用 `npm run e2e-server-native` 启动 Appium 服务端；

3、用 `npm run e2e-android` 启动 CodeceptJS 客户端，其会自动安装 `codecept.conf.js` 配置文件中的 `helpers.Appium.app` 并测试 `tests` 所指定的测试用例文件。

### Web
1、如果 `codecept.conf.js` 中的 `helpers.WebDriverIO.url` 是 `http://localhost:3000` ，则需要用比如 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 的 package.json 中的 `npm run web` 命令来开启 3000 端口上的网页；

2、用 `npm run e2e-server-web` 启动 Selenium 服务端；

3、用 `npm run e2e-web` 启动 CodeceptJS 客户端，其会自动用电脑上的浏览器打开 `codecept.conf.js` 中的 `helpers.WebDriverIO.url` 并测试 `tests` 所指定的测试用例文件。

## 远程测试
Appium 支持远程测试，这样就可以让一台电脑连着一台手机作为 Appium 服务端，然后另一台电脑（一般是持续集成 CI 系统）作为 CodeceptJS 客户端。具体操作也很简洁：

在手机系统设置的开发者选项中关闭“监控 ADB 安装应用”，以免每次换一个 apk 时需要手动点击手机屏幕上的“安装”按钮。

在服务端的项目目录中运行一次 `mkdir -p android/app/build/outputs/apk/`，然后运行 `npm run e2e-server-native` 即可。

在客户端的项目目录的 `./android/app/build/outputs/apk/` 中放置待测试的 `app-release.apk` ，然后运行 `package.json` 中的这个 script 以便将 apk 复制为服务端的 `./android/app/build/outputs/apk/app-release.apk` （因为稍后客户端在 `e2e-android-remote` 中会向服务端发送写在客户端 `codecept.conf.js` 中的 `./android/app/build/outputs/apk/app-release.apk` 这个信息，然后服务端会根据这个信息在服务端找这个文件 ） ：

    "e2e-android-remote-prepare": "sshpass -p 服务端登录密码 scp -o StrictHostKeyChecking=no ./android/app/build/outputs/apk/app-release.apk 服务端登录帐号@服务端地址:~/项目目录/android/app/build/outputs/apk/app-release.apk"

最后运行这个 script 进行测试：

    "e2e-android-remote": "codeceptjs run --profile=android --override '{\"helpers\": {\"Appium\": {\"host\": \"服务端地址\"}}}'",

哦……好吧，为了照顾 Windows 用户，这个 script 也可以调整为：

    "e2e-android-remote": "codeceptjs run --profile=android --override \"{\\\"helpers\\\": {\\\"Appium\\\": {\\\"host\\\": \\\"服务端地址\\\"}}}\"",

## 用例编写
因为 [testID 不支持 Android](https://github.com/facebook/react-native/pull/9942) 以及统一 Android 、 iOS 和 Web 的测试用例的需要，所以在产品组件中添加 accessibilityLabel 属性最合适，然后在测试用例中用 `~` 来定位该组件。

### 不适合添加 accessibilityLabel 属性的几种组件
* 用来引用其它自定义组件的引用组件
* Touchable 组件的子组件的最外一层组件

有时候用比如 CodeceptJS 的 I.seeElement('~个人中心') 抓取不到已经设过的 accessibilityLabel 属性，此时如果用 `I.grabSource().then(source => console.log(source))` 调试打印或是用 `android-sdk/tools/bin/uiautomatorviewer` 工具查看，就会发现整个页面的确没有那个属性值，这一般是由于上面所说的不适合添加 accessibilityLabel 属性的几种组件引起的。

用 `I.grabSource()` 有一个额外的好处，就是真实地反映了测试时的即时情况，比如用 uiautomatorviewer 看到存在 accessibilityLabel 所对应的 content-desc ，但是实际测试时抓取不到，用了 `I.grabSource()` 后才发现原来是没有及时将测试时自动安装运行的 APP 所自动弹出的“APP 需要使用您的位置权限”对话框给关闭，导致 `I.grabSource()` 抓取到的只是该对话框页面，而该对话框中是没有那个 accessibilityLabel 的。

### 编写 Page Object 和 Step Object 模式的测试用例
参照 [CodeceptJS 对 Page Object 和 Step Object 模式的说明](http://codecept.io/pageobjects/) ，另可参考 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 及更复杂的 [https://github.com/faikfaisal/Centricity-Automation](https://github.com/faikfaisal/Centricity-Automation) 和 [https://github.com/flyskywhy/codeceptjs4game](https://github.com/flyskywhy/codeceptjs4game) 。

## 疑难杂症
### 开始 Android 上的测试时抓取不到肯定存在的属性
进入 APP 的第一个页面，使用 `android-sdk/tools/bin/uiautomatorviewer` 工具能够看到，但是 CodeceptJS 就是抓取不到。原因和解决方法参见 [noder-react-native](https://github.com/flyskywhy/noder-react-native) 的 `e2e/steps/init.js` 中的 `workaroundOfStartNative()` 。
