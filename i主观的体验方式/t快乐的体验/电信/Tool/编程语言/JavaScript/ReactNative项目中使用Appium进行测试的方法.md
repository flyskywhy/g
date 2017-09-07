Li Zheng <flyskywhy@gmail.com>

# 环境搭建
## Appium
    npm install --save-dev appium wd jest

参考 [react-native-e2etest](https://github.com/garthenweb/react-native-e2etest) 中的如下内容添加进自己的 RN 项目代码中：

    package.json 中的 scripts 和 e2e
    e2e-config.js
    __tests__/basic.e2e.js

## Android

从 https://developer.android.google.cn 下载 sdk-tools-linux 成为比如

    ~/tools/android-sdk/

在 ~/.bashrc 中添加

    export ANDROID_HOME=~/tools/android-sdk
    PATH=~/tools/android-sdk/platform-tools:~/tools/android-sdk/tools:$PATH

安装 Appium 运行时所需的 adb ：

    ~/tools/android-sdk/tools/bin/sdkmanager platform-tools
    ~/tools/android-sdk/tools/bin/sdkmanager "build-tools;26.0.1"

## 图形界面
除了命令行方式，也可以看看 Appium 的 desktop application 图形界面的方式是否足够适用，详见 https://github.com/appium/appium-desktop （Windows 版的 Appium 图形界面程序可以在 https://github.com/appium/appium-desktop/releases 下载）。

# 启动
1、连接 Android 真机或启动 Android 模拟器（package.json 中 e2e 的 `"deviceName": "Android Emulator"` 配置是可以同时支持真机和模拟器的）。

2、用 `npm run start:appium` 启动 Appium 服务端。

3、按照 package.json 中 e2e 所述，放置 `./android/app/build/outputs/apk/app-release.apk` 文件。

4、用 `npm run test:e2e:android` 启动 Appium 客户端，其会自动安装 apk 并测试 `__tests__/` 目录中所有的 `*.e2e.js` 文件。

# 用例编写
编写时可关注 [react-native-e2etest](https://github.com/garthenweb/react-native-e2etest) 中关于 `accessibilityLabel vs. testID` 哪个更合适的讨论。

## 编写 Page Object 模式的测试用例
参考 [https://github.com/chrisprice/react-app-webdriver/tree/master/e2e](https://github.com/chrisprice/react-app-webdriver/tree/master/e2e) 中 pageObjects 和 specs 的写法。
