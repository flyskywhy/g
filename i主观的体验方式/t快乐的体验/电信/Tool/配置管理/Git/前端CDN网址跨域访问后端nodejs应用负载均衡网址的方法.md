Li Zheng <flyskywhy@gmail.com>

# 前端 CDN 网址跨域访问后端 nodejs 应用负载均衡网址的方法

## 肇因
本来如果能像 [gitlab 自动部署 nodejs 应用到阿里云 Kubernetes 集群中](GitLab自动部署nodejs应用到阿里云Kubernetes集群中.md) 所描述的前后端访问同一个域名从而不存在跨域问题，那是最方便的，无奈实际测试发现通过 CDN 来访问其回源的负载均衡提供的后端 API 性能相比直接通过负载均衡来访问会差 6 倍，即使改成号称能够提供动态加速功能的 CDN 的升级产品 DCDN [全站加速](https://dcdn.console.aliyun.com) 也基本改善不大，下表就是阿里云 [性能测试PTS](https://pts.aliyun.com/platinum) 所得的针对 nodejs 应用简单返回内存中数据的 API 的压力测试结果：

| 场景               | 平均TPS(次/秒)  | 平均RT(ms) | 起止时间                                       |
| :----------       | :------:       | :-------: | :-----------:                                 |
| www-get-cfg-dcdn  | 177.61         | 61.91     | 起：2018-09-28 09:44:53 止：2018-09-28 09:47:53 |
| www-get-cfg-nocdn | 899.66         | 11.02     | 起：2018-09-28 09:21:28 止：2018-09-28 09:24:28 |
| www-get-cfg-cdn   | 149.25         | 68.68     | 起：2018-09-28 09:13:09 止：2018-09-28 09:16:09 |

另外，如果 nodejs 应用提供了文件下载服务，则当文件较大时，在使用阿里云 [CDN](https://cdn.console.aliyun.com) 的情况下，就有非常大的概率下载失败，此种应用则只能让前后端使用不用域名使得后端不使用 CDN 。

## 方法
后端跨域设置可以在后端的 nginx.conf 或 nodejs 应用代码中设置，实际试验发现， nginx.conf 的跨域方法经常出现有一些 API 请求没有跨域成功的问题，而 nodejs 应用代码的跨域方法则全部跨域成功。

### 后端代码修改
这里以 nodejs 的 koa 框架所用的 [kcors](https://github.com/koajs/cors) 组件为例，后端添加如下代码：

```
var cors = require('kcors');

...

app.use(cors({
    credentials: true,
    origin: ctx => {
        // 带有 www. 前缀的是可能被 CDN 加速的前端静态网页的托管服务器地址，
        // 没有 www. 前缀的是不在 CDN 后面因而不会被 CDN 延时 6 倍左右的后端服务器地址

        // 如果前端网址本身就不带有 www. 前缀来访问，这里也是兼容性的
        // 兼容前后端网址相同比如都带有 www. 前缀的情况
        if (ctx.header.origin.replace(/^https?:\/\//, '').replace(/^www\./, '').replace(/:[0-9]+$/, '') === ctx.header.host.replace(/^www\./, '').replace(/:[0-9]+$/, '')) {
            return ctx.header.origin;
        }
    },
}));

```
### 后端域名解析
在 [云解析DNS](https://dns.console.aliyun.com) 中点击 `yourcompany.com` 的 `解析设置` ，在 `添加记录` 的对话框中， `记录类型` 选择 `A` ， `主机记录` 为 `@` ， `记录值` 为[负载均衡](https://slb.console.aliyun.com) 实例的 IP 地址，如此就将没有 `www.` 前缀的后端服务器地址 `yourcompany.com` 解析到直接负载均衡的 IP 地址。

### 前端代码修改
将前端代码中原有的 `www.yourcompany.com` 语句修改为 `yourcompany.com` ，或者是将原来的

    apiAddress = '';

修改为

    apiAddress = location.origin.replace(/:\/\/www\./, '://');


### 前端代码部署到 OSS
将前端代码部署到 OSS 地址而非原先后端 ECS 中的某个目录，并在 [对象存储 OSS](https://oss.console.aliyun.com) 的 `基础设置 | 静态页面` 设置 `默认首页` 为 `index.html`。

### 前端代码 CDN 加速
在 [CDN](https://cdn.console.aliyun.com) 的 `域名管理` 中 `添加域名` ， `加速域名` 设为 `www.yourcompany.com` ， `业务类型` 设为 `图片小文件` ， `源站信息` 设为部署着前端代码的 OSS 地址。

### 前端域名解析
在 [云解析DNS](https://dns.console.aliyun.com) 中点击 `yourcompany.com` 的 `解析设置` ，在 `添加记录` 的对话框中， `记录类型` 选择 `CNAME` ， `主机记录` 为 `www` ， `记录值` 为 CDN `域名管理` 中 `www.yourcompany.com` 的 CNAME ，如此就将带有 `www.` 前缀的前端静态网页的托管服务器地址 `www.yourcompany.com` 解析到 CDN 地址。