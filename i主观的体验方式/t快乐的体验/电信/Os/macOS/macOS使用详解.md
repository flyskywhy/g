Li Zheng flyskywhy@gmail.com

# macOS 使用详解

## 常用软件安装
参见 [React使用详解](../../Tool/编程语言/JavaScript/React使用详解.md) 中的 “配置 iOS 开发环境” 章节。

## macOS 升级
如果你的启动盘空闲容量不足 50GB ，请谨慎决定是否升级。当 macOS 出现升级提醒，你点击去升级，它提示需要下载比如 11 GB ，你看着空间勉强空余 12GB 多所以就去下了，万没料到下载到 9GB 时报错说空间不够（后面还会谈到此时会多出一个 9GB 的临时文件不会自动删除该怎么办）。你东挪西凑空出来后，终于下载好了，然后弹出个安装画面说需要 30GB 才能安装……在升级提醒下载前就不能提示一下总共所需容量么？更不要说苹果公司还发卖那种容量只有 120GB 的 MacBook ，你说装个 Xcode 就要十几 GB 然后编译几个项目代码就需要好几 GB 临时文件， 120GB 能顶啥用？而公司发给员工的工作用 MacBook 一般都是挑最廉价意味着容量最小的……总算经过钻研，发现使用下面谈到的文件清理方法花个一天时间一般能手工清理出 30GB 。而 macOS 升级后会自动删除 `/Applications/` 中下载的那个完整版 11GB 升级文件，苹果智商还算在线吧。

## 文件清理
首先 App Store 安装使用 `Cleaner One` 这个应用中的“智能扫描”自动清理一些缓存垃圾等等。

然后通过命令行逐个目录使用 `du -hd1` 列出每个子目录的容量使用情况，找到特别占空间的且经你自己分析或网上搜索得知能够删除的目录，比如下面这些：

    ~/Library/Developer/
    ~/Library/Caches/Google/ (一般应该已经被上面 `Cleaner One` 给清理掉了)
    ~/Library/Caches/CocoaPods/
    ~/Library/Caches/Homebrew/
    ~/go/
    ~/.gradle/
    ~/.npm/

macOS 比较奇葩的一点是它压根就没有提供“卸载”软件的功能，启动台中的应用程序快捷方式和 `/Applications/` 中的应用程序包根本就是互相独立管理的，你删除任何一个，都不会自动删除另外一个，至于其它的应用程序缓存等相关文件就更是如此了。

使用 Finder 文件管理器打开 `/Applications/` 时可以看到各个应用程序包的大小，自然首先将十几 GB Xcode 用鼠标右键菜单“移到废纸篓”再清空废纸篓，而那个几年前安装的几百 MB 现在膨胀（估计是自动升级文件占的空间）成了几个 GB 的 Chrome 自然也是如此处理。然后可以将 `~/Library/Application Support/Google/Chrome` 甚至 `~/Library/Caches/Google/` 移动到备份用的 U 盘上，这样 macOS 升级好后再复制回来再安装 Chrome ，则 Chrome 的 Google 登录状态、已打开的网页等等，都与 macOS 升级前相同。

可能需要移动备份再恢复回来的还有微信的 `~/Library/Containers/com.tencent.xinWeChat` 。

`Cleaner One` 这个免费版中的“应用程序管理”功能可以很容易跳转到各个应用程序相关文件的位置，这样就可以比较干净地手动卸载某个应用程序了。之所以不使用 `Cleaner One Pro` 这个收费版自动卸载应用程序，是因为其实有些相关文件它也没有找齐，那还不如一个个自己手动卸载呢。

比如其实很多应用程序在 `/private/var/folders/` 目录中有相关文件， `Cleaner One` 却根本就不管这个目录。

`/private/var/folders/` 这个目录主要都是临时文件，子目录中出现的 `T/` 是临时文件夹， `C/` 是缓存文件夹， `0/` 是用户数据文件夹，感觉都可以无脑删除，但保险起见，还是只删除 `du -hd1` 出来特别占空间的吧。

`/private/var/folders/` 中的 `zz/` 目录用于系统应用，与其平级的两个字符的目录用于用户账号，具体是哪个账号只要进入该目录中 `ls -l` 即可看到。

在 `/private/var/folders/` 中的 `zz/` 目录中 `ls -l` 可以看到各个子目录归属哪个系统应用，比如 `zyxvpxvq6csfxvn_n00000s0000068/` 就是属于 `_softwareupdate` 的，而且这个目录中存放的就是前面提到的那 macOS 升级文件下载失败时遗留的 9GB 临时文件，我们自然要删之而后快了。

其它还可以删除的占用很多空间的是

    /private/var/folders/两个字符的目录/d8q0gwfx0r11z2j3g9vnlxb00000gp/C/com.apple.DeveloperTools/All
