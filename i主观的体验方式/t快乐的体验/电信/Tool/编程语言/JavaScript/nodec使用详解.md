Li Zheng flyskywhy@gmail.com

# nodec 使用详解
为了加快 nodejs 应用部署速度和加密 JS 源代码，可以使用 [nodec](https://github.com/pmq20/node-packer) 来将 `index.js` `node_modules/` 等等编译为单独一个可执行文件，选择 nodec 的原因见这里的讨论 [How to make exe files from a node.js app](https://stackoverflow.com/questions/8173232/how-to-make-exe-files-from-a-node-js-app) 。

## 内存和交换空间需求
运行 nodec 时需要 10GB 左右的内存和 10GB 左右的交换空间，现在的 Ubuntu 默认安装时的交换文件为 2GB 左右，因此需要 [调整 Ubuntu 交换文件](../../../Os/Linux/调整Ubuntu交换文件.md) 。

## 缩减可执行文件尺寸的优化操作
运行 nodec 前可以做一些优化工作，比如将下面的优化操作写到你的自动部署脚本中，参考 [gitlab 自动部署 nodejs 应用到阿里云 Kubernetes 集群中](../../配置管理/Git/GitLab自动部署nodejs应用到阿里云Kubernetes集群中.md) ：
```
    rm -fr __tests__ android app index.android.js index.ios.js index.web.js ios # 删除后端运行时不需要的文件，以减小 nodec 最终生成的可执行文件大小
    rm -fr node_modules # nodec 会自动调用 npm install 的
    sed -i -e '/    "react/d' -e '/    "redux/d' -e '/    "rmc-/d' package.json # 去除前端依赖，以加快 nodec 自动调用的 npm install --production 运行速度
    sed -i -e "s/^{.*/{\"gitSha\":\"`git rev-parse --short HEAD`\",/" package.json # 如果 nodejs 应用中想要 git 哈希值的话可以这样做，因为 nodec 最终生成的可执行文件内部是不包含 .git/ 的
```
## 注意 __dirname 的使用场景
如果可执行文件运行时需要写文件比如 log 输出的，则 nodejs 应用代码里相关路径描述中不能带有
```
    __dirname + '/access.log'
````
这样的写法，而需要

    'access.log'

否则无法在可执行文件所在的目录中生成 access.log 文件。
