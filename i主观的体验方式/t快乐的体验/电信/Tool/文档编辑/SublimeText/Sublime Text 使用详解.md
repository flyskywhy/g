Li Zheng <flyskywhy@gmail.com>

# Sublime Text 使用详解

## 安装 Sublime Text
Sublime Text 在 [www.sublimetext.com](www.sublimetext.com) 上可以免费下载，而且运行时只会偶尔提示一下注册，并不影响免费使用。

## 自定义设置
在`Preferences | Settings - Default`中看到 JSON 格式所列出的某条想要修改的条目，只需再到`Preferences | Settings - User`中也按照 JSON 格式添加这一条条目即可。

### 设置等宽字体
在 Linux 下的 Sublime Text 如果不是等宽字体的，则添加

    "font_face": "DejaVu Sans Mono"，

### 转换 tab 为 space
如果需要转换，则添加

    "translate_tabs_to_spaces": true，

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

## 在 Package Control 中安装 Nodejs
这样就可以增加许多自动完成功能，比如敲入`fs`就会出现许多`fs.mkdir`等相关的函数可供选择。还有，菜单 `Tools | Snippet` 中也会多出几个代码段可供选择。

## 在 Package Control 中安装 Babel
支持 ES6 ， React.js ， jsx 代码高亮。

安装好后需进行配置：

* 打开 .js ， .jsx 后缀的文件
* 点击菜单 `view | Syntax | Open all with current extension as... | Babel | JavaScript (Babel)`

## 在 Package Control 中安装 SublimeLinter
这是使用各种语言的 lint 工具前需要安装的基础插件。

## 在 Package Control 中安装 SublimeLinter-contrib-eslint
由于 eslint 相比 jshint 多出了对最新代码格式比如 React 的支持，所以推荐安装 eslint 。

安装好 SublimeLinter-contrib-eslint 之后，还需如下操作：

### 实际项目中使用的复杂规则文件
在源代码目录中安装 eslint 可执行文件：

    npm install --save-dev babel-eslint eslint eslint-plugin-react

从 https://github.com/flyskywhy/noder-react-native 中复制 `.eslintrc` 文件到源代码目录。

### 解决规则文件没起作用的问题
这可能是 eslint 的一个 BUG ，解决的方法是再额外全局安装一下 eslint

    npm install -g eslint

然后在`Tools | SublimeLinter`临时把`Lint Mode`设定为`Load/save`，这样做以后，就可以在`Preferences | Package Settings | SublimeLinter | Settings - User`中看到一个完整的配置参数，在这些参数中的 `paths` 处设定好 eslint 可执行文件的所在路径比如在 `windows` 处添加 `"D:\\node\\bin"` ，最后把`Lint Mode`改回为`Background`。

### 简单规则文件示例
在源代码目录中安装 eslint 可执行文件：

    npm install --save-dev eslint eslint-plugin-jsx-a11y eslint-config-airbnb eslint-plugin-import eslint-plugin-react

在源代码目录中初始化 `.eslintrc` 文件，后续可再自行编辑：

    eslint --init

在初始化过程中回答如下问题即可：

    ? How would you like to configure ESLint? Use a popular style guide
    ? Which style guide do you want to follow? AirBnB
    ? What format do you want your config file to be in? JavaScript

这里选择 AirBnB 是因为 airbnb 的 [react 开发代码规范](https://github.com/airbnb/javascript/tree/master/react) 得到了许多开发者的点赞。

## 在 Package Control 中安装 SublimeLinter-jshint
安装好 SublimeLinter-jshint 之后，还需如下操作：

安装 jshint 可执行文件：

    npm install -g jshint

在源代码目录中建立`.jshintrc`文件，文件内容示例：

    {
        "esversion": 6
    }

然后如前所述在 `paths` 处设定好 jshint 可执行文件的所在路径。

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
这样就可以很容易让代码基于 = 或 : 等符号进行列对齐。

## 在 Package Control 中安装 JsFormat
这样就可以不用记忆 = 符号两边要加空格之类众多的编码规范。

为了支持 React 的 JSX 格式，需要打开 `preferences | Package Settings | JsFormat | Setting | Users` ，输入以下配置：

    {
        "e4x": true
    }
