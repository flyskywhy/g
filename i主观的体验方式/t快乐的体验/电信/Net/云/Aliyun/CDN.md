## 智能压缩
需要开启 `性能优化 | 智能压缩` ，否则网页加载速度很慢，使用 CDN 也就没有了意义。开启之后，对比原来未使用 CDN 而只使用 nginx 自带的压缩功能，页面首次加载时间提升了 2 ～ 6 倍。

## 回源host
如果前端静态文件不是放在 OSS 上而是 Web 服务器的某个目录中，而且该服务器上有一个以上监听 80 端口的程序，它们之间仅仅用 nginx 配置中的 server_name 来区分，那么回源这个 80 端口的 CDN 需要在 `回源设置 | 回源host` 中添加该 server_name 。

## 端口号
在 `www.yourcompany.com` 使用 CDN 后， `域名:端口号（非80,443）` 的方式将无法再使用，如果一些回调地址比如阿里云控制台 `消息服务 | 主题 | 订阅详情 | 接收端地址` 或者自己后端代码的配置文件中一些回调地址使用了端口号，则需相应改成非 CDN 访问的 `域名:端口号` 比如 `nocdn.yourcompany.com:1234`。

