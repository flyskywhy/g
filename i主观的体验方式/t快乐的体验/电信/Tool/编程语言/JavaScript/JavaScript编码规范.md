Li Zheng <flyskywhy@gmail.com>

大部分编码规范可以用 Sublime Text 编辑器的 SublimeLinter-contrib-eslint 插件来自动完成，详见 [Sublime Text 使用详解](../../文档编辑/SublimeText/SublimeText使用详解.md) 中的“ SublimeLinter-contrib-eslint ”小节和“ JsFormat ”小节，以及参照既有项目代码的格式，其它未尽事宜则记录在本文。

## 变量
申明变量时必须加 var (或 let)关键字。虽然 JavaScript 允许不加 var 关键字而成为全局变量，但这经常会引发 BUG 。

对于不需要变动的变量或者对象，统一使用 const 关键字，而不是 let (或 var)，let (或 var)因为可以修改，如果在其他地方无意中修改了该变量或者对象而导致 BUG ，需要花大量时间查找 BUG ， const 因为不能修改所以没有这个烦恼。

需要变动的变量或者对象，建议使用 let 代替 var 。

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
值得注意的是，不要在函数定义时在参数中直接使用空对象如 `function foobar({}) {}` ，否则有可能出现 `undefined is not a function(evaluating 'babel Helpers.objectDestructuringEmpty(_ref5)')` ，解决的办法是修改为：

    function foobar(query = {}) {}

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
循环体 for( in ) 的性能损失是 for( of ) 或者 for(;;) 的 10 倍，性能最好的是 for(;;) ，基本上 for( of ) 和 for(;;) 的性能比是 2:3 的样子，考虑到 for( of ) 写起来比 for(;;) 方便因而不容易手误，所以尽量使用 for( of ) ，如果需要 index 的才使用 for(;;) 。

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

## npm
避免将 package-lock.json 放入 git 仓库中，而仍然通过去掉 package.json 中的 ^ 或 ~ 符号的方式来固定版本，原因如下：

* node8.x 自带的 npm （比如 npm5.5.1）存在无法配合 package-lock.json 完成 `npm install` 的情况，参见 [NPM Cannot read property '0' of undefined](https://stackoverflow.com/questions/46619949/npm-cannot-read-property-0-of-undefined) 。
* 有的项目成员会使用 npm 自带的仓库，有的会使用淘宝的镜像仓库，导致 package-lock.json 这个同时也记录着仓库地址的巨大文件实际上难以解决合并冲突，而且会使 ~/.npm 目录中存在大量重复的缓存文件而白白占用硬盘空间。
* 不使用 yarn 及其 yarn.lock 的原因，是因为每次运行 yarn 命令就会将 node_modules 干干净净地重置一遍，的确很 lock ，但是实际项目开发过程中项目成员常常会实验性地修改 node_modules 中的某个第三方组件，有时也会用 `npm postinstall` 对一些第三方组件打补丁，而且有时因为中国网络环境的原因，需要手动到第三方组件中添加一些自动安装过程中没有从比如亚马逊网站上下载的压缩包，所以 yarn 的这个“干净”功能反而会带来很多繁琐的重复操作。

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

### Fiber 架构
从 react-native 0.44.0 开始使用了 react 16 ，计算机系统架构中 Fiber 是比线程还要精细的纤程(或者说协程)， react 16 中的 Fiber 和系统架构中的 Fiber 不一样，指的是对渲染过程精细的调整，类似于操作系统中进程调度的分片，据说大大提高了性能，不过 Fiber 会导致 render 之前的生命周期可能被调用数次，参考 [React Fiber是什么](https://zhuanlan.zhihu.com/p/26027085) 中所说“只剩下componentWillMount和componentWillUpdate这两个函数往往包含副作用，所以当使用React Fiber的时候一定要重点看这两个函数的实现”，因此编写代码时也要注意保证这两个函数被重复调用时不会产生副作用。

Fiber 架构是为了解决之前 React 存在的问题而提出来：
* 问题1，之前 React 渲染是一个同步的动作，当组件庞大时，渲染时间比较长，因为是同步的，无法被打断，所以在这过程中的其他操作都是没有反应的。
* 问题2，之前 React 所有的渲染没有优先级可言，导致 React 逮住哪个组件就渲染哪个。

### setState
不应在 render() 中调用比如 this.setState({foo: bar}) ，而只是在 render() 中使用别的地方设置好的数据比如 this.state.foo ，否则会出现 “Warning: Cannot update during an existing state transition (such as within `render` or another component's constructor). Render methods should be a pure function of props and state; constructor side-effects are an anti-pattern, but can be moved to `componentWillMount`.”

还有就是要注意 [在React组件unmounted之后setState的报错处理](http://www.cnblogs.com/libin-1/p/6667442.html)

### addListener
设置监听器去监听事件比如 addListener() 的时间点需要在触发事件之前。这个倒不是 React 所独有而是所有编程语言或框架都应如此。这里以一个 react-native 的用于管理阿里云 oss 中文件的第三方组件的一个提交点为例子 [解决 iOS 无法上传的问题，虽然有些编译出来的应用能够上传，但只是凑巧罢了，因为设置监听时间按正常流程必须要 早于触发事件](https://github.com/flyskywhy/react-native-aliyun-oss/commit/eb68565636f4e0276cdd8a234a44d962e46481ed)

### Keyboard
当键盘出现时，可以调整一下页面布局以更美观。参考 [Comment.js](https://github.com/soliury/noder-react-native/blob/master/src/layouts/Comment.js) 中如下语句调整组件高度的方式：
```
    Keyboard.addListener('keyboardDidShow', this.updateKeyboardSpace.bind(this))
...
  updateKeyboardSpace (e) {
    LayoutAnimation.configureNext(animations.keyboard.layout.spring)
    this.commentsView && this.commentsView.setNativeProps({
      style: {
        height: commentsHeight - e.endCoordinates.height
      }
    })
  }
```
### Touchable 系列组件
使用 Touchable 系列组件，如果进行 setState 时发现卡顿严重或者需要进行大量掉帧操作，可以使用以下方式解决卡顿问题：
```
    onPress =　() => {
        requestAnimationFrame(() => {
            // todo
        });
    }
```
### 无状态组件
无状态组件是一个 render 方法，并没有组件类的实例过程，也没有实例返回。没有状态，没有生命周期，只有简单接受 props 渲染成 DOM 结构，有简单、便捷、高效等诸多优点，如果可能，尽量使用无状态组件。

构造方法1：
```
    const HiTitle = (props) => (
        <Text>
            {props.title}
        </Text>
    )
```
构造方法2：
```
    const HiTitle = (props) => {
        const {
            title
        } = props;
        return (
            <Text>
                {title}
            </Text>
        );
    }
```
无状态组件既然可以接收 props ，那么也就可以设置 propTypes 和 defaultProps
```
    HiTitle.propTypes = {title: PropTypes.string}
    HiTitle.defaultProps = {title: 'stateless component'}
```
使用：
```
    <HiTitle />
```
### react-v16 render 可以返回数组和字符串
* 返回数组

例子：
```
    const RenderMultiple = () => [
        <Text> 11111</Text>,
        <Text> 22222</Text>,
        <Text> 33333</Text>
    ];
```
使用：
```
    <RenderMultiple />
```
* 返回字符串

例子:
```
    const RenderString = () => 'Hello world';
```
使用：
```
    <Text>
        <RenderString />
    </Text>
```
* 返回字符串数组

例子:
```
    const RenderArrayOfString = () => [
      'A',
      'B',
      'C'
    ];
```
调用:
```
    <Text>
        <RenderArrayOfString />
    </Text>
```
* 返回数组的数组(二维数组)

例子:
```
    const RenderArrayOfArray = () => [
      [
        <Text>S1</Text>,
        <Text>S2</Text>,
      ],
      [
        <Text>What</Text>,
        <Text>Ever</Text>,
      ]
    ];
```
调用:
```
        <RenderArrayOfArray />
```
* 如果返回数组时报警告说需要一个不相等的 key ，则要么在 props 中添加 key ，要么通过以下代码避免这个警告

例子:
```
    const Wrap = (props) => props.children;
    const WrapContainer = () => (
    <Wrap>
       <Text>hello</Text>
       <Text>world</Text>
    </Wrap>
```
使用:
```
    <WrapContainer />
```

### shouldComponentUpdate
自定义 Test组件
```
    调用情况 1 ： <Test style={styles.test}/>
    调用情况 2 ： <Test style={{backgroundColor: 'red', width: 20, height: 20}}/>
    调用情况 3 ： <Test style={[{backgroundColor: 'red'}, {width: 20, height: 20}]}/>
    调用情况 4 ： const style = {backgroundColor: 'red', width: 20, height: 20}; 写在 render 方法内部， <Test style={styles}/>
    调用情况 5 ： const style = {backgroundColor: 'red', width: 20, height: 20}; 写在 class 类外部， <Test style={styles}/>
    调用情况 6 ： const this.style = {backgroundColor: 'red', width: 20, height: 20}; 写在 render 方法内部， <Test style={this.styles}/>
    调用情况 7 ： const this.style = {backgroundColor: 'red', width: 20, height: 20}; 写在 constructor 方法内部， <Test style={this.style}/>
```
情景 1 ： Test 组件继承自 PureComponent
```
    调用情况 1 ：父组件重新 render，不会触发 Test 组件重新 render
    调用情况 2 ：父组件重新 render，会触发 Test 组件重新 render
    调用情况 3 ：父组件重新 render，会触发 Test 组件重新 render
    调用情况 4 ：父组件重新 render，会触发 Test 组件重新 render
    调用情况 5 ：父组件重新 render，不会触发 Test 组件重新 render
    调用情况 6 ：父组件重新 render，会触发 Test 组件重新 render
    调用情况 7 ：父组件重新 render，不会触发 Test 组件重新 render
```
情景 2 ： Test 组件继承自 Component
```
    上述 7 种调用情况，父组件重新 render，都会触发 Test 组件重新 render
```
情景 3 ： Test 组件继承自 BaseComponent
```
import React, {
    Component
} from 'react';
import Immutable from 'immutable';

class BaseComponent extends Component {

    shouldComponentUpdate(nextProps, nextState = {}) {
        return !Immutable.is(Immutable.fromJS(this.props), Immutable.fromJS(nextProps))
        || !Immutable.is(Immutable.fromJS(this.state), Immutable.fromJS(nextState));
    }
}

export default BaseComponent;
```
```
    上述 7 种调用情况，父组件重新 render，都不会触发 Test 组件重新 render
```
总结： shouldComponentUpdate 返回 true ，表示该组件需要重新 render ，反之不需要。 PureComponent 中重写了 shouldComponentUpdate ，内部实现是一个浅比较——普通数据类型比较内容、 object 类型数据比较地址。 BaseComponent 中重写了 shouldComponentUpdate ，利用 Immutable 实现每个字段值的比较。
