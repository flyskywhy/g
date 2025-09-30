Li Zheng flyskywhy@gmail.com

# Firebase 使用详解
Firebase 提供的 Crashlytics 崩溃报告或后端服务等功能，是需要在 APP 中集成 firebase SDK 的，比如 `npm install @react-native-firebase/app` ，不过如果只是使用 Test Lab 功能的话，则不用那么麻烦。

Firebase 默认是免费的，参见[Firebase需要花钱吗？](https://blog.back4app.com/zh/firebase%E9%9C%80%E8%A6%81%E8%8A%B1%E9%92%B1%E5%90%97/)和[Firebase Pricing](https://firebase.google.com/pricing?hl=zh-cn)。

## 创建 Firebase 项目
登录 Google 帐号，并进入 <https://console.firebase.google.com/>

点击“创建项目”

* 请先为项目输入名称

输入一个名称比如 APP 名称，就会自动生成项目的唯一标识符，然后点击“继续”。

注，其实不一定需要使用 APP 名称作为项目名称，因为比如使用 Test Lab 功能时，其实是可以选择任意 APP 来进行测试的。

* 为您的 Firebase 项目设置 Google Analytics（分析）

既然其介绍“Google Analytics（分析）是一款免费且无限制的分析解决方案，可让您在使用 Firebase Crashlytics、Cloud Messaging、In-App Messaging、Remote Config、A/B Testing 和 Cloud Functions 时，执行定位、报告及其他操作”这么强大，那就勾选“为此项目启用 Google Analytics（分析）”吧（除非你确定只使用 Test Lab 功能），然后点击“继续”。

* 配置 Google Analytics（分析）

“分析位置”选择“中国”，想要启用基准化分析功能，估计也只能选中“与 Google 共享 Analytics 数据，启用基准化分析功能”，然后点击“创建项目”。

## Test Lab 在 Google 托管的设备上对应用和游戏进行并发测试
点击“发布与监控 | Test Lab”进入该页面。 Robo 测试是不需要预先编写的测试，它支持在 Android 和 iPhone 真机上测试。

初次进入 Test Lab 页面，点击“Robo 测试 支持 APK、AAB和IPA”旁的“浏览”选择一个 apk 文件后，就会自动上传并进入一个 APP 名称为名的页面，从页面中的设备详情可以看到，已经默认使用“Pixel 5，API 级别 30”在进行测试了，大概十分钟左右测试就会完成。

再次进入 Test Lab 页面，可以看到 APP 列表，里面包含“测试矩阵”列表和“运行测试”按钮。

刚才自动创建的测试就被列在“测试矩阵”列表中，等它的图标从时钟表盘形状的“待处理”状态变为对勾形状“成功”状态，就可以点击进去然后在“测试结果”列表中的“Pixel 5，API 级别 30”上点进去查看文字报告、 APP 各页面截屏图片、 APP 运行过程屏幕录制视频等等。

如果要进行一次全新测试，点击“运行测试 | Robo”按钮即可，此时除了可以“浏览”选择相应的 APP 文件，还可以选择其它设备比如“Galaxy S22 Ultra，API 级别 33”等等。

由于默认的 [Test Lab 的用量级别、配额和价格](https://firebase.google.com/docs/test-lab/usage-quotas-pricing?authuser=0&hl=zh) 是 Spark 方案（免费）：资源限制以每日测试运行总次数的形式列出，最多每天 15 次：

* 每天在虚拟设备上运行 10 次测试
* 每天在实体设备上运行 5 次测试


所以当天“运行测试 | Robo”时也只能选择最多 4 个实体设备了。

可以在 Test Lab 页面的“预设内容”中预先选择好 5 个实体设备以方便今后测试选择。

## 解决 @react-native-firebase/app 编译问题
参见 <https://github.com/flyskywhy/react-native-gcanvas/issues/72#issuecomment-1869305099>
