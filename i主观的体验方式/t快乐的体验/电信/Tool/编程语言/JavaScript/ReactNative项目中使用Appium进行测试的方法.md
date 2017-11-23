Li Zheng <flyskywhy@gmail.com>


## 基本架构

* 测试用例代码调用测试客户端比如 [CodeceptJS](https://github.com/Codeception/CodeceptJS)
* 测试客户端调用测试服务端比如 [Appium](https://github.com/appium/appium) 或 [Selenium](https://github.com/SeleniumHQ/selenium)
* 测试服务端连接 Android 、 iOS 或 Web 以运行 RN 程序

## 环境搭建
    npm install --save-dev appium webdriver-manager codeceptjs-webdriverio mocha

在 package.json 的 scripts 一节中添加如下内容：

    "e2e-update-server-web": "webdriver-manager update --versions.gecko=v0.18.0",
    "e2e-server-web": "webdriver-manager start --versions.gecko=v0.18.0",
    "e2e-web": "codeceptjs run",
    "e2e-server-native": "appium",
    "e2e-android": "codeceptjs run --profile=android",
    "e2e-ios": "codeceptjs run --profile=ios"

在 package.json 的 devEngines 一节中添加如下内容：

    "node": ">= 6.11.1"

运行如下命令以安装 Selenium

    npm run e2e-update-server-web

为了让 Web 也能像 Android 和 iOS 那样用 `~` 来定位同一个 accessibilityLabel 而无需修改测试用例，需参照 [Increase ~ considerable speed in Appium and support ~ with aria-label in WebDriverIO](https://github.com/Codeception/CodeceptJS/pull/728) 这个 Pull Request 对前面下载好的 codeceptjs-webdriverio 打补丁。

使用 [CodeceptJS 命令行自动生成示例文件](http://codecept.io/commands/) ，了解 CodeceptJS 所需的测试用例代码的文件结构，然后参考 [https://github.com/faikfaisal/Centricity-Automation](https://github.com/faikfaisal/Centricity-Automation) 完善自己所需的测试用例代码的文件内容，还可参考更复杂的 [https://github.com/timestampx/4game](https://github.com/timestampx/4game) 。

这里是一个 `codecept.conf.js` 配置文件的示例，配合上面的 package.json 就可以很容易地切换 Android 、 iOS 和 Web 分别进行测试：
```
let CODECEPT_WORK_PATH = './test-mocha/app';

exports.config = {
    output: CODECEPT_WORK_PATH + '/output',
    helpers: process.profile === 'android' || process.profile === 'ios' ? {
        Appium: {
            smartWait: 35000,
            app: process.profile === 'android' ? './android/app/build/outputs/apk/app-release.apk' : './ios/build/Build/Products/Release-iphonesimulator/e2etest.app',
            platform: process.profile === 'android' ? 'Android' : 'iOS',
            desiredCapabilities: {
                platformVersion: process.profile === 'ios' ? '10.3' : undefined,
                deviceName: process.profile === 'ios' ? 'iPhone Simulator' : 'Android Emulator'
            }
        }
    } : {
        WebDriverIO: {
            url: 'http://localhost:3000',
            browser: 'firefox'
        },
        ReactWeb: {
            require: CODECEPT_WORK_PATH + '/helpers/reactweb_helper.js'
        }
    },
    include: {
        I: CODECEPT_WORK_PATH + '/custom_steps.js',
        initStep: CODECEPT_WORK_PATH + '/steps/init.js',
        AllowLocationFragment: CODECEPT_WORK_PATH + '/fragments/AllowLocation.js',
        generalPage: CODECEPT_WORK_PATH + '/pages/general.js',
        HomePage: CODECEPT_WORK_PATH + '/pages/Home.js',
        LoginPleasePage: CODECEPT_WORK_PATH + '/pages/LoginPlease.js',
        LoginPage: CODECEPT_WORK_PATH + '/pages/Login.js',
        UserPage: CODECEPT_WORK_PATH + '/pages/User.js'
    },
    mocha: {},
    bootstrap: false,
    teardown: null,
    hooks: [],
    tests: CODECEPT_WORK_PATH + '/tests/*.js',
    timeout: 10000,
    name: 'YourProjectName'
};
```
这里是 reactweb_helper.js` 文件的示例：
```
'use strict';

class ReactWeb extends Helper {
    runOnIOS(caps, fn) {
        return;
    }

    runOnAndroid(caps, fn) {
        return;
    }

    runInWeb(fn) {
        return fn();
    }
}

module.exports = ReactWeb;
```

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

## 启动
### Android
1、编译出 apk 并连接 Android 真机或启动 Android 模拟器；

2、用 `npm run e2e-server-native` 启动 Appium 服务端；

3、用 `npm run e2e-android` 启动 CodeceptJS 客户端，其会自动安装 `codecept.conf.js` 配置文件中的 `helpers.Appium.app` 并测试 `tests` 所指定的测试用例文件。

### Web
1、如果前面用的是 `http://localhost:3000` ，则需要用比如 [noder-react-native](https://github.com/flyskywhy/noder-react-native/blob/master/package.json) 中的 `npm run web` 命令来开启 3000 端口上的网页；

2、用 `npm run e2e-server-web` 启动 Selenium 服务端；

3、用 `npm run e2e-web` 启动 CodeceptJS 客户端，其会自动用电脑上的浏览器打开 `codecept.conf.js` 配置文件中的 `helpers.WebDriverIO.url` 并测试 `tests` 所指定的测试用例文件。


## 用例编写
因为 [testID 不支持 Android](https://github.com/facebook/react-native/pull/9942) 以及统一 Android 、 iOS 和 Web 的测试用例的需要，所以在组件上添加 accessibilityLabel 属性最合适。

### 不适合添加 accessibilityLabel 属性的几种组件
* 用来引用其它自定义组件的引用组件
* Touchable 组件的子组件的最外一层组件

有时候用比如 CodeceptJS 的 I.seeElement('~个人中心') 抓取不到已经设过的 accessibilityLabel 属性，此时如果用 `I.grabSource().then(source => console.log(source))` 调试打印或是用 `android-sdk/tools/bin/uiautomatorviewer` 工具查看，就会发现整个页面的确没有那个属性值，这一般是由于上面所说的不适合添加 accessibilityLabel 属性的几种组件引起的。

用 `I.grabSource()` 有一个额外的好处，就是真实地反映了测试时的即时情况，比如用 uiautomatorviewer 看到存在 accessibilityLabel 所对应的 content-desc ，但是实际测试时抓取不到，用了 `I.grabSource()` 后才发现原来是没有及时将测试时自动安装运行的 APP 所自动弹出的“APP 需要使用您的位置权限”对话框给关闭，导致 `I.grabSource()` 抓取到的只是该对话框页面，而该对话框中是没有那个 accessibilityLabel 的。

### 编写 Page Object 和 Step Object 模式的测试用例
参照 [CodeceptJS 对 Page Object 和 Step Object 模式的说明](http://codecept.io/pageobjects/) ，另可参考 [https://github.com/faikfaisal/Centricity-Automation](https://github.com/faikfaisal/Centricity-Automation) 及更复杂的 [https://github.com/timestampx/4game](https://github.com/timestampx/4game) 。

## 疑难杂症
### 开始 Android 上的测试时抓取不到肯定存在的属性
进入 APP 的第一个页面，使用 `android-sdk/tools/bin/uiautomatorviewer` 工具能够看到，但是 CodeceptJS 就是抓取不到。原因和解决方法如下：

steps/init.js
```
/// <reference path="../steps.d.ts" />
'use strict';

let I, AllowLocationFragment, generalPage, WelcomePage;

module.exports = {
    _init() {
        I = require('../custom_steps.js')();
        AllowLocationFragment = require('../fragments/AllowLocation');
        AllowLocationFragment._init();
        generalPage = require('../pages/general');
        generalPage._init();
        WelcomePage = require('../pages/Welcome');
        WelcomePage._init();
    },

    workaroundOfStartNative() {
        // 发现在 Android 上测试时，必须先弹出这种比如位置权限的对话框，然后返回，
        AllowLocationFragment.permissionAllow();

        // 再配合一些 APP 画面的改变比如这里对 Welcome 也就是引导页面的滑动，才能
        // 让后续的比如 ~ 符号开头的 accessibilityLabel 表示的页面元素被顺利抓取
        // 以开始正常测试。
        // 这里实际上只需要滑动 1 次就可以让测试正常了，不过为了配合 4 幅引导页，简
        // 便起见，直接滑动了 3 次。
        // 另外，如果 APP 一开始能自己做一些画面的改变比如 toast 显示一个字符，则这
        // 里的滑动操作就不再需要了。
        I.runOnAndroid(() => {
            generalPage.swipeLeft(3);
        });
        I.runOnIOS(() => {
            generalPage.swipeLeft(3);
        });
    },

    toHome() {
        I.runInWeb(() => {
            I.amOnPage('/');
        });

        this.workaroundOfStartNative();

        I.runOnAndroid(() => {
            WelcomePage.clickStart();
        });
        I.runOnIOS(() => {
            WelcomePage.clickStart();
        });
    }
};
```
pages/general.js
```
/// <reference path="../steps.d.ts" />

// Page object for General page (shared element/operations across all pages)
'use strict';

let I;

module.exports = {
    _init() {
        I = actor();
    },

    swipeLeft(count) {
        for (let i = 0; i < count; i++) {
            I.touchPerform([{
                action: 'press',
                options: {
                    x: 400,
                }
            }, {
                action: 'moveTo',
                options: {
                    x: -300,
                }
            }, {
                action: 'release'
            }, {
                action: 'wait',
                options: {
                    ms: 100,
                }
            }]);
        }
    }
};
```
fragments/AllowLocation.js
```
/// <reference path="../steps.d.ts" />
'use strict';

let I;

module.exports = {
    _init() {
        I = require('../custom_steps.js')();
    },

    permissionOkButton: {
        android: {
            id: 'com.android.packageinstaller:id/permission_allow_button'
        }
    },

    permissionAllow() {
        this.permissionOkButton[process.profile] && I.click(this.permissionOkButton[process.profile]);
    }
};
```
pages/Welcome.js
```
/// <reference path="../steps.d.ts" />
'use strict';

let I;

module.exports = {
    _init() {
        I = require('../custom_steps.js')();
    },

    clickStart() {
        I.click('~马上启动');
    }
};
```
