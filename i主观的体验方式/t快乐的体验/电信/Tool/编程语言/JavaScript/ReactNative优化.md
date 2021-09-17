Li Zheng <flyskywhy@gmail.com>

# React Native 优化

## redux 性能优化
首先需要知道，即使 `mapStateToProps()` 中没什么内容，只要 redux 的 store 有改变，仍然会被执行。

如果使用 store 数据的组件代码的 `mapStateToProps()` 中使用如 `...state.userScreenUI` 这样的写法，当 action 触发 `userScreenUI` 中 state 改变，则比如 `react-navigation` 的 router 栈中所有使用 `...state.userScreenUI` 的写法来进行返回的 `mapStateToProps()` 所在组件的 render 方法将会被触发，无论该组件界面是否可见，也就是说引发了不必要的渲染。

因此请不要在 `mapStateToProps()` 中返回当前组件用不到的值。可以采用将 `...state.userScreenUI` 手动展开成比如 `pullRefreshPending: state.userScreenUI.pullRefreshPending` 的写法，这样就算 action 触发了 `state.userScreenUI` 这个引用值的改变，但只要 `state.userScreenUI.pullRefreshPending` 这个比如 boolean 类型的非引用值没有改变，就不会重新 render 。当然如果是为了比如跟随浏览器（通过 `react-native-web` 运行）页面大小改变而改变所特别添加的类似 `width: state.utils.width` 这样的则不算没有用处的值，因为就算 `render()` 中没有用到 width ，我们也是希望 width 改变时重新 render 的，而  `mapStateToProps()` 返回 width 这个非引用值在改变时，就能重新 render 。

总之，只要 `mapStateToProps()` 返回的那些 props 中有引用值，且引用值会改变的，在没有使用下面提到的 `shouldComponentUpdate()` 和 `react-fast-compare` 组件来不比较引用的地址（也就是引用值）而只比较具体内容的情况下，就会重新 render 。因此值得注意的是，还有一种隐含情况程序员可能会漏掉，也就是下面的写法
```
export function mapStateToProps(state, props) {
  const someArray = state.device.someArray || [];

  return {
    someArray, // 这种写法在 someArray 被赋值为上面的 [] 时就会触发重新 render
    // someArray: state.device.someArray, // 这种写法在 state.device.someArray 没有改变时不会重新 render
    height: state.utils.height,
    width: state.utils.width,
  };
}
```
会由于 `[]` 写法实际上是在内存中 new 了一个新数组对象并将该对象的引用值赋给了 `someArray` ，此时 `mapStateToProps()` 以之返回的话就会重新 render 。

一句话，只要 `mapStateToProps()` 返回的那些 props 中有引用值，最好就使用 `shouldComponentUpdate()` 和 `react-fast-compare` 组件进行配合。

## [react-fast-compare](https://github.com/FormidableLabs/react-fast-compare) 组件
之所以 `react-fast-compare` 组件很重要，是因为 redux 的 store 改变时，整个 store 的 state 的引用地址都改变了（ redux 使用的是复制并修改的原理），因此只要不是 number 或 string 之类的直接值，而是 `[]` 或 `{}` 之类的引用值，都需要借助 `react-fast-compare` 组件来进行修改与否的判断。

之所以不使用比较流行的 immutable 组件而使用 `react-fast-compare` 组件，是因为发现 `immutable.is()` 方法无法正确比对数组（至少在 `immutable@3.8.2` 上发现有这个问题）

如果你的代码中用到了除 `immutable.is()` 之外的其它 immutable 数据结构，则可能需要让 `react-fast-compare` [Working with Immutable.js structures](https://github.com/FormidableLabs/react-fast-compare/issues/42) 。

## 生命周期函数性能优化
在 `react.Component` 组件中添加如下生命周期函数代码即可基本避免不必要的重新渲染：
import isEqual from 'react-fast-compare';

```
  shouldComponentUpdate(nextProps, nextState = {}) {
    return !isEqual(this.props, nextProps) || !isEqual(this.state, nextState);
  }
```
另外，即使在 `shouldComponentUpdate()` 中使用 `react-fast-compare` 组件判断从而避免了重新 render ，但是避免不了生命周期函数 `getDerivedStateFromProps()` 的执行，因此如果使用了 `getDerivedStateFromProps()`  ，就可能需要在 `getDerivedStateFromProps()` 也应用 `react-fast-compare` 组件判断。

## Text 控件
Android 默认背景是透明的， iOS 默认有个白色的背景，造成很多 UI 在 iOS 上显示不正常，如果不使用 Text 的背景时，可将背景设置为透明

    backgroundColor: 'transparent'

## 其它

* [How I improved my React Native app 50x faster](https://blog.inkdrop.info/how-i-improved-my-react-native-app-50x-faster-13d566061e84)
* [How to control the existing React Native view instance from another native module](https://dev.to/craftzdog/how-to-control-the-existing-react-native-view-instance-from-another-native-module-3doi)
* [Inter-communication between native modules on React Native](https://dev.to/craftzdog/inter-communication-between-native-modules-on-react-native-57bn)
* [How we reduced our production apk size by 70% in React Native?](https://dev.to/srajesh636/how-we-reduced-our-production-apk-size-by-70-in-react-native-1lci)
* [How I Reduced the Size of My React Native App by 86%](https://medium.com/@aswinmohanme/how-i-reduced-the-size-of-my-react-native-app-by-86-27be72bba640)
* [[译]通过几个简单的修改，我们减少了React Native app 60%的大小](https://cloud.tencent.com/developer/article/1661002)
* [Optimizing React Native](https://blog.coinbase.com/optimizing-react-native-7e7bf7ac3a34)
* [React Native Performance: Do and Don’t](https://medium.com/crowdbotics/react-native-performance-do-and-dont-88424e873bbd)
* [How We Improved React Native List Performance by 5X](https://medium.com/hackernoon/how-to-improve-react-native-list-performance-5x-times-b299c8a23b5d)
