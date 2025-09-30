Li Zheng flyskywhy@gmail.com

# BoneEngine 使用详解
简介见 [BoneEngine@Lite背景介绍](https://aliosthings.gitbook.io/docs/documentation/components/middleware/boneengine-lite)

## eval 命令行使用

    eval "for (i = 0\; i < 2\; i++) {print(7)}"

由上可知几点：

* 如果有空格存在的，则需要用引号包起来
* 如果是 for 语句，则里面的分号前面需要加倒斜杠
* 全局变量可以不用 var 或 let 进行定义就可以直接赋值
```
    eval "var a = function(b){print(b)}\; var i = 0"
    eval "while (i < 3) {a(i) i++}"
```
由上可知几点：

* 前后 eval 中的 JS 代码是共享一个上下文的
* 类似 var 赋值语句后面必须加倒斜杠和分号
* 其它很多情况下两条语句之间也可以用空格而非分号隔开

另：命令行 JS 字符不能超过 200 个

## 其它 JS 语法限制
### 不支持没有必要的结尾逗号
没有必要的结尾逗号需要去除，比如

    Integer.parseInt(10.1,10,)

会报错而

    Integer.parseInt(10.1,10)

不会。

另外，这里可以简写成

    Integer.parseInt(10.1)

### 不支持语法
* 双感叹号 !!
* 按位取反 ~
