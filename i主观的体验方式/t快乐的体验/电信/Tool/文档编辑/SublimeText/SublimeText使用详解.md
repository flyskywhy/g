Li Zheng flyskywhy@gmail.com

# Sublime Text 使用详解

## 安装 Sublime Text
Sublime Text 在 [www.sublimetext.com](http://www.sublimetext.com) 上可以免费下载，而且运行时只会偶尔提示一下注册，并不影响免费使用。

在 Ubuntu 上还可以用如下简便的方法进行安装：

    sudo add-apt-repository ppa:webupd8team/sublime-text-3
    sudo apt-get update
    sudo apt-get install sublime-text-installer

## 自定义设置
在`Preferences | Settings - Default`中看到 JSON 格式所列出的某条想要修改的条目，只需再到`Preferences | Settings - User`中也按照 JSON 格式添加这一条条目即可。

### 设置等宽字体
在 Linux 下的 Sublime Text 如果不是等宽字体的，则添加

    "font_face": "DejaVu Sans Mono",

### 转换 tab 为 space
如果需要转换，则添加

    "translate_tabs_to_spaces": true,

### 设置换行符为 LF
Sublime Text 默认新文件的换行符为系统相关，这样 Windows 下的话就是 CRLF 了。为了可能的 bash 脚本批量处理时不出问题以及减小文件体积，设为 LF 更合适，方法为添加

    "default_line_ending": "unix",

### 自动删除行尾的空白字符（空格或制表符）
    "trim_trailing_white_space_on_save": true,

## 阅读 javascript 源代码
Sublime Text 自带的函数跳转 F12 快捷键非常给力，理解起代码来方便多了。

## 选定文件夹查找
Nodejs 代码会包含一个自动下载的包含了许多许多文件的 node_modules 目录，此时如果简单使用 Sublime Text 查找菜单中的文件夹查找功能或是使用 grep 命令，会返回许多我们不需要的 node_modules 中的搜索结果。解决方法是在 Sublime Text 的侧边栏用 Ctrl 键加鼠标左键的方式选中想要查找的文件夹，然后右键菜单进行查找。另外，在 Linux 中还可以使用 ag 命令来进行查找， ag 会自动忽略 `.gitignore` 文件里指定的目录。

## 在 Sublime Text 中安装插件管理工具 Package Control
把 [https://packagecontrol.io/installation](https://packagecontrol.io/installation) 网页上显示的 Python 语句复制下来，点击 Sublime Text 的菜单`View | Show Console`，在打开的 Console 中粘帖 Python 语句并回车，稍后根据提示重启 Sublime Text 即可使用菜单`Preferences | Package Control`来`Install Package`安装各种强大的插件了。

注：可参考 [解决国内 https://packagecontrol.io 无法访问的问题](https://github.com/HBLong/channel_v3_daily) 。

## 在 Package Control 中安装 Nodejs
这样就可以增加许多自动完成功能，比如敲入`fs`就会出现许多`fs.mkdir`等相关的函数可供选择。还有，菜单 `Tools | Snippet` 中也会多出几个代码段可供选择。

## 在 Package Control 中安装 Babel
支持 ES6 ， React.js ， jsx 代码高亮。

安装好后需进行配置：

* 打开 .js ， .jsx 后缀的文件
* 点击菜单 `view | Syntax | Open all with current extension as... | Babel | JavaScript (Babel)`

## 在 Package Control 中安装 SublimeLinter
这是使用各种语言的 lint 工具前需要安装的基础插件。

## 在 Package Control 中安装 SublimeLinter-eslint
以及在你自己项目源代码目录中安装 eslint 可执行文件及 react-native 社区默认采用的规则文件：

    npm install --save-dev @babel/core @babel/runtime @react-native-community/eslint-config eslint

为了使用上面的默认规则文件，还需在你自己项目源代码目录添加顶层的简单规则文件 `.eslintrc.js` ，参考自 react-native 0.60
```
module.exports = {
  root: true,
  extends: '@react-native-community',
};
```
有时可能也有一些自己额外的规则想添加，比如有个全局变量 location 并不想让 SublimeLinter-eslint 提示个红框出来，那就可以将上面的顶层规则文件修改为：
```
module.exports = {
  root: true,
  extends: '@react-native-community',
  globals: {
    location: false,
  },
};
```

### 解决规则文件没起作用的问题
这可能是 eslint 的一个 BUG ，解决的方法是再额外全局安装一下 eslint

    npm install -g eslint

如果不存在 `/usr/bin/node` ，则还需

    sudo ln -s `which node` /usr/bin/node

## 在 Package Control 中安装 JsPrettier
使用 eslint 来提示代码规范编写问题，使用 prettier 来自动修改代码以符合代码规范，这样就达到了其它语言格式化工具比如 go 语言的 gofmt 的效果——不用再争论哪种代码规范更合适了，直接用 prettier 格式化代码即可。

在上面安装 @react-native-community/eslint-config 时，已经自动安装了 prettier 可执行文件，现在只需在你自己项目源代码目录添加它的配置文件 `.prettierrc.js` ，参考自 react-native 0.60
```
module.exports = {
  bracketSpacing: false,
  jsxBracketSameLine: true,
  singleQuote: true,
  trailingComma: 'all',
};
```
终于你只需要在 Sublime 中右键菜单 `JsPrettier Format Code` 就可格式化当前打开的 `js` 文件了。

## 在 Package Control 中安装 SublimeAStyleFormatter
使用 SublimeAStyleFormatter 来自动修改 `C/C++/C#/Java` 代码以符合代码规范。

可在 `preferences | Package Settings | SublimeAStyleFormatter | Settings - User` 中输入以下参考配置以比较贴近 JsPrettier 的风格：
```
{
    "autoformat_on_save": false,

    "options_default": {
        "style": "kr",
        "indent": "spaces",
        "indent-spaces": 4,
        "indent-switches": true,
        // "indent-cases": true,
        "add-brackets": true,
        "keep-one-line-blocks": false,
        "unpad-paren": true,
        "pad-header": true,
        "pad-comma": true,
    },
    "options_c": {
        "additional_options": ["--convert-tabs"]
    },
    "options_c++": {
        "additional_options": ["--convert-tabs"]
    },
    "options_java": {
        "additional_options": ["--convert-tabs"]
    },
    "options_cs": {
        "additional_options": ["--convert-tabs"]
    }
}
```
终于你只需要在 Sublime 中右键菜单 `AStyleFormatter | Format` 就可格式化当前打开的 `c/h/cpp/cs/java` 文件了。

## 在 Package Control 中安装 Color Highlighter
这样就可以直观地在 `.css` 文件中 `color:` 的十六进制数值上通过左键单击看到颜色，还可以在右键菜单中选择颜色。

## 在 Package Control 中安装 DocBlockr
这样就可以写出很标准的函数注释。

## 在 Package Control 中安装 Emmet 和 LiveStyle
这两个插件可以极大提高前端人员的效率。

Emmet 可参见这篇文章 [前端开发必备！Emmet使用手册](http://www.w3cplus.com/tools/emmet-cheat-sheet.html)

LiveStyle 可参见这篇文章 [Emmet LiveStyle 无刷新同步修改预览](http://www.dbpoo.com/sublime-emmet-livestyle/)

如果安装后重启 Sublime Text 时出现如下错误：

    Error while loading PyV8 binary: exit code 3

那意味着由于网络问题而连接 github.com 超时，解决方法是在 `View | Show Console` 中查看发现比如是这样的下载语句错误：

    https://raw.github.com/emmetio/pyv8-binaries/master/pyv8-linux64-p3.zip

于是手动将这个文件下载下来后解压缩为 `~/.config/sublime-text-3/Installed Packages/PyV8/linux64-p3/` 即可。

## 在 Package Control 中安装 Modific
在保存文件后可以看到相对于上一次 git 提交点的修改之处。

## 在 Package Control 中安装 OmniMarkupPreviewer
这样就可以在浏览器中实时预览 markdown 文件。

## 在 Package Control 中安装 All Autocomplete
这样就可以在敲代码时也能自动匹配到其它文件中的某个变量。

## 在 Package Control 中安装 AlignTab
这样就可以很容易让代码基于 = 或 : 等符号进行列对齐。当然，最好是使用上面提到的 JsPrettier 。

## 在 Package Control 中安装 JsFormat
这样就可以不用记忆 = 符号两边要加空格之类众多的编码规范。当然，最好是使用上面提到的 JsPrettier 。

为了支持 React 的 JSX 格式，需要打开 `preferences | Package Settings | JsFormat | Settings - User` ，输入以下配置：
```
    {
        "e4x": true
    }
```
