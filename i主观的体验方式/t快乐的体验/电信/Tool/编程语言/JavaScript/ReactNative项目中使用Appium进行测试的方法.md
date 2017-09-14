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
因为 [testID 不支持 Android](https://github.com/facebook/react-native/pull/9942)，所以在组件上添加 accessibilityLabel 属性更合适。

### 不适合添加 accessibilityLabel 属性的几种组件
* 用来引用其它自定义组件的引用组件
* Touchable 组件的子组件的最外一层组件

有时候用 driver.hasElementByAccessibilityId() 获取不到已经设过的 accessibilityLabel 属性，此时如果用 driver.source().then(console.log) 调试打印或是用 `android-sdk/tools/bin/uiautomatorviewer` 工具查看，就会发现整个页面的确没有那个属性值，这一般是由于上面所说的不适合添加 accessibilityLabel 属性的几种组件引起的。

用 driver.source().then(console.log) 有一个额外的好处，就是真实地反映了测试时的即时情况，比如用 uiautomatorviewer 看到存在 accessibilityLabel 所对应的 content-desc ，但是实际测试时获取不到，用了 driver.source().then(console.log) 后才发现原来是没有及时将测试时自动安装运行的 APP 所自动弹出的“APP 需要使用您的位置权限”对话框给关闭，导致 driver.source() 抓取到的只是该对话框页面，而该对话框中是没有那个 accessibilityLabel 的。

## 编写 Page Object 模式的测试用例
参考 [https://github.com/chrisprice/react-app-webdriver/tree/master/e2e](https://github.com/chrisprice/react-app-webdriver/tree/master/e2e) 中 pageObjects 和 specs 的写法。
