Li Zheng flyskywhy@gmail.com

# JavaScript 精选包
安装各种包后，JavaScript 就变得更强大。安装 [nodejs](nodejs.org) 之后就能使用 npm 命令。

## sequelize
使用NodeJS来关系型操作数据库时， Sequelize 是一个比较合适的 ORM(Object Relationship Model) 框架。参见 [Sequelize 和 MySQL 对照](https://segmentfault.com/a/1190000003987871) 一文。

## arr-pluck
由 sequelize 的 findAll 查出来的结果是数组里面包含着 key-value 对象，但有时候只想要一个扁平的 value 数组，这时候 [arr-pluck](https://github.com/jonschlinkert/arr-pluck) 就能派上用场了。

例子：

    var pluck = require('arr-pluck');

    var role_ids = yield user_roles.findAll({
        where: {
            user_id: 7
        },
        attributes: ['role_id']
    }).then(function(data) {
        return pluck(data, 'role_id');
    });

## array-unique
一般来说可以设置成让 sequelize 的 findAll 查出来的结果数组是去重的，但有时自己写的代码还是需要进行数组去重，而 JavaScript 没有自带数组去重命令，自己再去编码实现去重则比较累赘且不一定有比较好的性能，还好现在有号称速度最快的 [array-unique](https://github.com/jonschlinkert/array-unique) 。

用法：

    var unique = require('array-unique');

    unique(['a', 'b', 'c', 'c']);
    //=> ['a', 'b', 'c']

## ndb
[ndb](https://github.com/GoogleChromeLabs/ndb) 可以进行设断点、内存性能测试等操作，参见在 Chrome 70 及之后版本中 [Debug Node.js apps with ndb](https://developers.google.com/web/updates/2018/08/devtools#ndb) 。

## 阿里云 Node.js 性能平台
可参考 [Node应用内存泄漏分析方法论与实战](https://help.aliyun.com/document_detail/64011.html) 和 [Trace用户指南](https://help.aliyun.com/document_detail/72715.html) 等文章。
