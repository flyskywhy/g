# Go 使用详解

## 配置`GOROOT`
配置环境变量`GOROOT`为 Go 语言开发包的安装目录，并将`$GOROOT/bin`加入`PATH`。如果不使用命令行编译，而只使用后续所描述的 Android Studio 开发环境的，也可以不配置该环境变量。

## 配置`GOPATH`
新建存放着各种第三方 go 源代码甚至包括你自己的源代码的根目录，比如`~/golang`，并按照`go help gopath`中的要求，在该目录中精确地建立子目录`src`、`pkg`、`bin`。

配置环境变量`GOPATH`为`~/golang`。如果不使用命令行编译，而只使用后续所描述的 Android Studio 开发环境的，也可以不配置该环境变量。

## 免翻墙但能正常使用`go get`的方法
要使用`go get`，前提是要先设置好`GOPATH`，比如：

    export GOPATH=$HOME/golang

因为墙，所以普遍使用的`go get`命令时，经常会报找不到`golang.org/x/tools/go/vcs`之类的错误，就算`https://github.com/golang/`是`golang.org/x`的镜像，但针对`github`进行的`go get`也还是会有问题，所以这里需要描述一下在不把命令行终端也折腾出翻墙功能的情况下正常使用`go get`的方法。

    cd $GOPATH
    mkdir -p src/github.com/golang
    mkdir -p src/golang.org
    cd src/golang.org
    ln -s ../github.com/golang x

现在你就可以正常使用`go get`了。最好是首先：

    go get github.com/golang/tools

然后比如你想从`tools/cmd/goimports/`目录中编译出`goimports`这个可执行文件到`bin/`目录中，就可以使用如下命令：

    go get golang.org/x/tools/cmd/goimports

## go module
现在很多 `go` 语言所写的项目源代码会使用 `go module` 进行依赖管理，在 `go get` 时会自动安装这些依赖。如果因为墙导致安装这些依赖时出现网络错误，则需要

    export GOPROXY=https://goproxy.io

## godep
以前许多 `go` 语言所写的项目源代码中，会有一个`Godeps`目录，这个目录其实是由`godep save`命令自动生成的。

虽说`Godeps`目录也可以不存在，而由`go get`命令所获取的`$GOPATH`目录中的各个`package`来解决项目依赖问题，但大型项目一般依赖众多，所以为方便计都会使用`godep`。

要使用`godep`，首先当然是安装它自身：

    go get github.com/tools/godep

然后比如你的`foo.go`源代码中的`import`语句那里有对于`github.com/xxx/bar`的依赖，则接着需要安装`bar`到本地的`$GOPATH`中：

    go get github.com/xxx/bar

接着进入`$GOPATH/src/github.com/xxx/bar`中使用`gitk --all`图形界面确认所需的版本（提交点），最后就可以在`foo.go`源代码所在的目录比如`foobar/src/`中使用如下命令来将该版本的`bar`代码（不含`.git`目录）自动复制到`Godeps`目录中了：

    export GOPATH=$GOPATH:$HOME/proj/foobar
    cd $HOME/proj/foobar/src
    godep save

现在你也完全可以删除`$GOPATH/src/github.com/xxx/bar`目录了，只不过如果这样做了，下次运行`godep save`前还得先`go get`一下。

编译`foo.go`的方式，如果是在后面描述的 Android Studio 图形界面中进行编译的情况下，则先需要将`Godeps/_workspace`加入到`Go Libraries`中（同时也删除`$GOPATH/src/github.com/xxx/bar`目录以免 Android Studio 因在两个地方找到`github.com/xxx/bar`而报错）再进行编译；如果是在命令行界面且没有将`Godeps/_workspace`加入`$GOPATH`环境变量的情况下，则可在`foo.go`所在的目录中使用如下命令之一：

    godep go run foo.go
    godep go build
    godep go install

## 为 Android Studio 添加 Go 语言开发环境
Android Studio 是基于最强大的收费的 IntelliJ IDEA 而开发的，而 Android Studio 是免费的，这样只要再添加 Go 插件，Android Studio 就变成了免费的编辑、编译、运行、单步调试 Go 语言的强大 IDE。

### 下载免费的 Android Studio

去[Android Tools Project Site](http://tools.android.com/recent)或[Android Studio 中文社区](http://android-studio.org)下载最新版的 Android Studio。

### 安装 Go 插件
在 Android Stuido 的`File | Settings | Plugins | Browse repositories`中安装 Go 这个插件（或是`Install plugin from disk...`本地安装从[https://plugins.jetbrains.com/plugin/5047](https://plugins.jetbrains.com/plugin/5047)下载的`.zip`文件），然后重启 Android Studio 使插件生效。

### 在 Android Studio project 中添加 Go 源代码 module
因为不是原版的 IntelliJ IDEA，所以无法直接新建 Go project，而是需要通过一个新建`.go`文件的动作来触发 Go 插件的触发流程，所以我们首先需要在新建 Android Studio project 的向导对话框中选择"Add No Activity"（或是其它的也可以），因为其自动生成的 app 这个 module 文件夹中的大部分文件后续我们都会删除。

在 Android Studio 左侧的 Project 侧边栏中，在`app/src`下新建你自己的 package 的子目录比如`foo/bar/`，然后在`foo/bar/`上鼠标右键菜单`New | Go File`，输入文件名比如`demo.go`，选择`Simple Application`，点击`OK`后，就会弹出`Setup SDK`和`Change module type to Go and reload project`的提示信息。

点击`Setup SDK`，然后在`Configure... | + | Go SDK | Select Home Directory for Go SDK`对话框中选择 go 的安装目录。这样就相当于设置了`GOROOT`。

如果此前没有设置过`GOPATH`环境变量，则此时又会弹出`Configure Go Libraries`的提示信息，点击后，在`Global libraries | +`对话框中选择`~/golang`

点击`Change module type to Go and reload project`，在弹出的`Update Module Type`对话框中点击`Reload project`，这样就会把`app`这个 module 的类型从`JAVA_MODULE`转换为`GO_MODULE`。

此时又会弹出一个`GOPATH was detected`的提示信息，点击其中的`Go Libraries configuration`，然后`Project libraries | +`选择`app`所在的目录。最后再在`GOPATH was detected`提示信息右上角的`×`符号上点击以关闭该提示信息。

（以上一些配置操作以后可以在`File | Settings | Languages & Frameworks | Go`里面找到）

接着在`File | Project Structure... | Project Settings | Modules | app | Dependencies | Module SDK`中选择`Go`，并把除了`Go`和`<Module source>`以外的依赖删掉。同时顺便也把`File | Project Structure... | Project Settings | Modules | app`中的 Android 和 Android-Gradle 这两个 facet 勾上`Ignore`选项，以免经常弹出 facet 错误提示信息。

现在，编辑`.go`文件时你就可以享受到强大的自动完成功能了！

### 在 Android Studio project 中更方便地添加 Go 源代码 module
在做完上述添加 module 的操作后，精确来说，是在完成`Change module type to Go and reload project`那一步后，后续再添加新的 module 会非常方便，而且甚至能方便地添加不在当前 project 目录下的 Go 源代码目录。

方法是在 Android Studio 左侧的 Project 侧边栏中的某个 module 比如`app`上，右键菜单`Open Module Settings`或是`File | Project Structure...`，然后`Module | + | New Module | Go`，再在`Next`对话框中选中`Project SDK`中的`Go`，最后在`Next`对话框中的`Module name`处填入你想在当前 project 目录下新建的 Go 源代码目录的名字，或是在`Content root`处选择不在当前 project 目录下的 Go 源代码目录。另外还需要到`File | Settings | Languages & Frameworks | Go | Go Libraries | Project libraries | +`选择新添加的 module 所在的目录。

### 在 Android Studio project 中编译、运行、单步调试 Go 程序
点击工具栏上运行按钮旁的下拉菜单，选择`Edit Configurations...`，然后在`+ | Go Application`中：

* `Name`填写将要生成的可执行文件的文件名比如示例`demo.go`所在的文件夹的名字`bar`就比较合适；
* `Run kind`选择`Package`，然后在`Package`那里填写类似`foo/bar`这样的相对路径（这里如果报错则说明你还没有设置好前面所提到的`Project libraries`），这样的好处是后续在`app/src/foo/bar/`中放置的多个`.go`文件之间可以互相调用对方的函数；
* `Run kind`选择`File`，然后在`File`那里填写`demo.go`的全路径（右边的`...`按钮选择更方便），这种情况下只能编译运行一个`.go`文件；
* `Output directory`中选择`app/bin`所在的全路径（可以使用右边的`...`按钮里面的新建文件夹功能来新建这个`bin`目录）。
* `Working directory`中选择`app/src/foo/bar`所在的全路径。

最后，你就可以使用工具栏上运行或是调试按钮，来享受到图形界面调试程序的便利了。

### 删除 Go 源代码 module 中无用的 Android 代码
在 app 这个 module 中，把除了`app.iml`、`bin/`、`src/foo/bar/demo.go`之外的所有文件和文件夹全部删除即可。如果是另外新建 Go 的 module 的，则可以把 app 这个旧的 module 文件夹完全删除了。
