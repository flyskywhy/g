Li Zheng <flyskywhy@gmail.com>

大部分编码规范可以用 Sublime Text 编辑器的 SublimeLinter-contrib-eslint 插件来自动完成，详见 [Sublime Text 使用详解](../../文档编辑/SublimeText/SublimeText使用详解.md) 中的“ SublimeLinter-contrib-eslint ”小节和“ JsFormat ”小节，以及参照既有项目代码的格式，其它未尽事宜则记录在本文。

## 变量
申明变量时必须加 var (或 let)关键字。虽然 JavaScript 允许不加 var 关键字而成为全局变量，但这经常会引发 BUG 。

## 对象
使用对象展开运算符 ... 复制对象:
```
// bad
const original = { a: 1, b: 2 };
const copy = Object.assign(original, { c: 3 });

// good
const original = { a: 1, b: 2 };
const copy = { ...original, c: 3 };
```

## 数组
使用数组展开运算符 ... 复制数组:
```
// bad
const len = items.length;
const itemsCopy = [];
let i;
for (i = 0; i < len; i++) {
  itemsCopy[i] = items[i];
}

// good
const itemsCopy = [...items];
```

将类似数组的对象转换成一个数组，使用 Array.from :
```
const foo = document.querySelectorAll('.foo');
const nodes = Array.from(foo)
```

## 条件表达式
条件表达式例如 if 语句通过抽象方法 ToBoolean 强制计算它们的表达式并且总是遵守下面的规则：

* 对象 被计算为 true
* Undefined 被计算为 false
* Null 被计算为 false
* 布尔值 被计算为 布尔的值
* 数字 如果是 +0、-0 或 NaN 被计算为 false，否则为 true
* 字符串 如果是空字符串 '' 被计算为 false，否则为 true
```
if ([0]) {
// true
// 一个数组就是一个对象，对象被计算为 true
}
```
## 循环体
循环体 for( in ) 的性能损失是 for( of ) 或者 for(;;) 的 10 倍，所以尽量使用 for( of ) ，如果需要 index 的才使用 for(;;) 。

Object 无法 .length ，所以不能改成相应的 for(;;) ，只能用 for( in ) 。

Array 是可以 .length 的，所以使用 for( of ) 或者 for(;;) 皆可。

可以使用 [无循环 JavaScript](http://www.linuxeden.com/a/3359) 一文中提到的 Array 自带的 map() 等方法来替代耦合较大的 for 语句，并提高代码可读性。

## 数字
如 [js 字符串转换成数字的三种方法](http://blog.csdn.net/ufo2910628/article/details/40735691) 之类的文章所说，

    '2' - 0

的结果是

    数字 2

但复杂情况下，比如下面的代码会有问题：

    '2' + '2' - 0

其结果是

    数字 22

就算是

    '2'- 0 + '2' - 0

其结果也还是

    数字 22

解决的方法是：

    '2' * 1 + '2' * 1

上面的 * 1 也可以用 / 1 代替，或者用 parseInt() 也是另一种标准做法。

## React
### 方法顺序
继承 React.Component 的类的方法遵循下面的顺序：
```
constructor
optional static methods
getChildContext
componentWillMount
componentDidMount
componentWillReceiveProps
shouldComponentUpdate
componentWillUpdate
componentDidUpdate
componentWillUnmount
clickHandlers or eventHandlers like onClickSubmit() or onChangeDescription()
getter methods for render like getSelectReason() or getFooterContent()
Optional render methods like renderNavigation() or renderProfilePicture()
render
```
使用 require('create-react-class').createClass 时，方法顺序如下：
```
displayName
propTypes
contextTypes
childContextTypes
mixins
statics
defaultProps
getDefaultProps
getInitialState
getChildContext
componentWillMount
componentDidMount
componentWillReceiveProps
shouldComponentUpdate
componentWillUpdate
componentDidUpdate
componentWillUnmount
clickHandlers or eventHandlers like onClickSubmit() or onChangeDescription()
getter methods for render like getSelectReason() or getFooterContent()
Optional render methods like renderNavigation() or renderProfilePicture()
render
```
eslint rules: [react/sort-comp](https://github.com/yannickcr/eslint-plugin-react/blob/master/docs/rules/sort-comp.md)

### fiber
从 react-native 0.44.0 开始使用的 react 16 ，采用了比线程还要精细的 fiber （纤程或者说协程），据说大大提高了性能，不过呢，参考 [React Fiber是什么](https://zhuanlan.zhihu.com/p/26027085) 中所说“只剩下componentWillMount和componentWillUpdate这两个函数往往包含副作用，所以当使用React Fiber的时候一定要重点看这两个函数的实现”，因此编写代码时也要注意保证这两个函数被重复调用时不会产生副作用。

### setState
不应在 render() 中调用比如 this.setState({foo: bar}) ，而只是在 render() 中使用别的地方设置好的数据比如 this.state.foo ，否则会出现 “Warning: Cannot update during an existing state transition (such as within `render` or another component's constructor). Render methods should be a pure function of props and state; constructor side-effects are an anti-pattern, but can be moved to `componentWillMount`.”

还有就是要注意 [在React组件unmounted之后setState的报错处理](http://www.cnblogs.com/libin-1/p/6667442.html)

### addListener
设置监听器去监听事件比如 addListener() 的时间点需要在触发事件之前。这个倒不是 React 所独有而是所有编程语言或框架都应如此。这里以一个 react-native 的用于管理阿里云 oss 中文件的第三方组件的一个提交点为例子 [解决 iOS 无法上传的问题，虽然有些编译出来的应用能够上传，但只是凑巧罢了，因为设置监听时间按正常流程必须要 早于触发事件](https://github.com/flyskywhy/react-native-aliyun-oss/commit/eb68565636f4e0276cdd8a234a44d962e46481ed)
