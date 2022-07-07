Upgrade to macOS 10.12.6

Xcode 9.1

Security Update 2017-001

optimize some

https://brew.sh

brew install node

npm install -g react-native-cli

    npm config set registry https://registry.npm.taobao.org --global

brew install watchman

gitlab-runner register to shell

    http://docs.gitlab.com/runner/install/osx.html
    And set macOS to auto login with account runner

gilab-runner OK with `~/builds/` and `~/cache/`

    `npm run ios` OK
    `npm run build-ios` OK, just js build in ~/builds/

Remote Login enabled by ssh

    系统偏好设置 | 选择共享 | 点击远程登录

xcodebuild OK
```
Double click *.mobileprovision in ~/Downloads/ , now you can see the provision in "Xcode".

Double click *.p12 in ~/Downloads/ , import them into System Keychain, then in "KeyChain Access", find related private key, and set it's `Access Control` to `Allow all applications to access this item`. Now can `xcodebuild archive -scheme YourProject -destination generic/platform=iOS -archivePath bin/YourProject.xcarchive -quiet` . Ref to [使用 xcodebuild 从 archive 导出 ipa](https://blog.reohou.com/how-to-export-ipa-from-archive-using-xcodebuild/) .

Ref to [Xcode9 xcodebuild export plist 配置](http://www.jianshu.com/p/6b68cd9307bc) to get the `ExportOptions.plist` , now can `xcodebuild -exportArchive -archivePath bin/YourProject.xcarchive -exportPath bin/YourProject -exportOptionsPlist development-ExportOptions.plist` .

`sudo visudo` , add `%staff          ALL = NOPASSWD: /usr/sbin/ntpdate`, now can run `sudo ntpdate -u time.apple.com` without password, and thus newly added `/usr/local/bin/ossutilmac64` can access aliyun with the corrected date

npm install -g code-push-cli
```
brew install wget

only put .gitignore in `~/cache/YourProject/default/cache.zip`

disble app store auto update
