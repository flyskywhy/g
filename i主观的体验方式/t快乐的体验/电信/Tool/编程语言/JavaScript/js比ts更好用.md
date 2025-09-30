Li Zheng flyskywhy@gmail.com

# js 比 ts 更好用

在

中文版[从Sun离职后，我“抛弃”了Java，拥抱JavaScript和Node](http://www.linuxeden.com/a/35938)

英文版[Why is a Java guy so excited about Node.js and JavaScript?](https://blog.sourcerer.io/why-is-a-java-guy-so-excited-about-node-js-and-javascript-7cfc423efb44)

中，该作者认为编程语言的类型检查敝大于利。

我也认为越简单越省时间，因此我对冗杂的 flow 和 typescript 表示反感。

该文主旨是，通过类型检查的方式来提升健状性所花的代价太大，得不偿失，况且因为增加了复杂性而导致不见得有多健状。该文意思利用 node 模块边界清晰的特性再加上单元测试更有利于健状性。

我同意抛弃了 java 的该文作者的观点——基于 javascript 和 node 包管理的特点，类型检查在 javascript 中敝大于利。

我的额外现点—— flow 或 typescript 是给那些从 java 转型过来又惯性使然教条地认为编程语言就应该需要类型检查的那些程序员所开发的妥协产物。

关健问题是类型检查需要改动应用代码，而测试代码是不需要改应用代码的，因此在 js 这种语言本身就对类型检查不太感冒的特点的情况下，“要改动应用代码”增加复杂性，就成了类型检查与测试对比的最后一根用来压垮的稻草。

因此我赞成单元测试和 e2e 测试，但反对类型检查。

奥卡姆剃刀原则：若无必要，勿增实体

我写代码时也遵循该原则，比如昨天试下来新增的 `joi-browser` 这个第三方组件运行良好，于是不认为另外一人 fork 并修改而成的 `joi-react-native` 必要性有多大，直到今天发现编译 release 版 apk 时出问题，才替换成了 `joi-react-native` 。

有人认为这样是过渡实践奥卡姆剃刀——将所有从小到大的坑都要自己踩一遍是不值得的，但我要说，前文作者已总结过类型检查总体上看不利于代码理解和修改，而且这难道不就是从别人身上在学习么，上面这样只是因为没人写过 `joi-react-native` 相关的文档而已。

如果某个阶段的的主要工作是重构优化代码，则需要避免过程中制造出新 bug ，所以测试是必须伴随重构一起进行的，本来就需要花精力在协调重构和测试这两者，因此如果再要花精力在重构代码时考虑类型检查的相应修改（就好比多写了代码注释结果改代码时还要相应修改注释），结果最重要的部分——重构优化代码本身得不到足够的时间思考，这就是本末倒置了。

有人认为需要再花大量时间去思考或实践前文作者说的类型检查让代码不容易理解的观点是否正确，但我要说，那么多文章的道理一个个去验证是否正确得花多少时间？所以我的方法是“巨量网页工作法”——读尽量多的文章，正反都有，然后就可以认定谁说的有道理了，一如我终于认定了中医不可信。

有人对我“巨量网页工作法”质疑也很正常，因为我们从小受的教育就是“绝知此事须躬行”，但我已经提前意识到这个教育信条，在互联网带来海量信息的那一刻就已经过时了。人类几千年来的日常是，那些读书人难得遇到一本新书，日常闲暇时间又大把，合理的方式或者说个人能力的体现自然是亲自验证下新知识是否正确。然而随着最近几十年信息多到无人能有时间将之全部验证，此后重点已永久改变为选择知识的能力。《未来简史》里面描绘的也是如此。

我赞成对 API 参数用第三方模块 joi 进行类型检查，原因一是 API 与语言特定的函数调用无关，而是独立于语言类型之外的网络调用，二是因为通过将原有零散在各个 API 实现代码中的参数检查集中定义到 `common/api.js` 这一个文件中，这实际上是降低了代码的复杂度。

我反对对 JS 函数调用做类型检查，至少不需要所有变量或参数添加类型检查，因为这样会增加很多冗余代码，且对于代码理解没啥好处。下面的文章里列出了函数调用类型检查的众多利弊，按照巨量网页工作法自然可以得出的结论—— JS 语言类型检查弊大于利。

* 类型检查方法——通过代码约束如原生 JavaScript 或者 ES6 的语法对类型的判断，或是工具库如 lodash

[How to better check data types in javascript](https://webbjocke.com/javascript-check-data-types/)

[Comparing Type Checks in JavaScript](http://engblog.yext.com/post/js-type-checking)

[ES-基础-——-类型检测](https://juejin.im/entry/59986731f265da247e7d90a3)

* 类型检查方法——依赖静态类型检测工具，如 Flow

[Flow使用](https://segmentfault.com/a/1190000008088489)

[Flow官方指南](https://flow.org/en/docs/getting-started/)

* 静态类型检查的优劣势及使用原则参考文档

[Why use static types in JavaScript?](https://medium.freecodecamp.org/why-use-static-types-in-javascript-part-1-8382da1e0adb)

[Why use static types in JavaScript? The Advantages and Disadvantages](https://medium.freecodecamp.org/why-use-static-types-in-javascript-part-2-part-3-be699ee7be60)

[So should we use static types in JavaScript or not?](https://medium.freecodecamp.org/why-use-static-types-in-javascript-part-4-b2e1e06a67c9)

[You Might Not Need TypeScript (or Static Types)](https://medium.com/javascript-scene/you-might-not-need-typescript-or-static-types-aa7cb670a77b)

[The Shocking Secret About Static Types](https://medium.com/javascript-scene/the-shocking-secret-about-static-types-514d39bf30a3)

关于 TypeScript ，如[Flow使用](https://segmentfault.com/a/1190000008088489)中所说，“需要把已经在使用的应用代码，都要整个改用TypeScript代码语法，才能发挥完整的功用” ，这个一般不用程序员说，就算不写代码的产品经理也不会同意开发团队如此推倒重写已上线代码的。

关于 Flow ，一般认为 Vue 算是业界大佬了吧？上面某链接文章内容里也有个链接文章是[Vue 2.0 为什么选用 Flow 进行静态代码检查而不是直接使用 TypeScript？](https://www.zhihu.com/question/46397274)，所以如果能够摸索好 Flow 在编辑器中很容易自动提示以及 RN 和 Web 打包时去除 Flow 的方法，同时确认已解决 Flow 运行效率不高导致电脑运行卡顿的问题，那我倒是不反对 Flow 在一些场景中采用，因为毕竟 react-native 框架代码本身也使用了 Flow ，了解一些 Flow 语法对于阅读 react-native 代码是有好处的。

刚才提到“一些场景”，是指“比较核心重要或者涉及安全的功能模块，最好添加类型检查”。

如果一定要在这些场景中采用类型检查，那我也要啰嗦地建议———采用的时机是在重构组件化和单元测试之后，理由还是不要过分分散重构所需的思考时间而导致本末倒置。

如果已经决定要在某些函数引用第三方静态类型检查，那还是用 flow 最省时间——因为一旦不小心扩散成了每个函数都用了 flow ，到时才发现敝大于利，就可以用一条 flow 自带命令删除所有 flow 语句。

最后，关于函数调用，我更偏好的观点还是完全不刻意另外使用 flow 之类的模板侵入代码的方式做函数类型检查，而是使用 React 自带的 PropTypes 和偶尔程序员自己按需用原生 js 代码检查一下函数参数就够了。
