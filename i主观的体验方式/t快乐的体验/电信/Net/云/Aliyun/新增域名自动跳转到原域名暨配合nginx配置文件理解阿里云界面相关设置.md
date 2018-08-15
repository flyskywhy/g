Li Zheng <flyskywhy@gmail.com>

# 新增域名自动跳转到原域名暨配合nginx配置文件理解阿里云界面相关设置
域名自动跳转可以在 nginx 配置中进行，也可以在 html 中进行， nginx 方法的缺点是需要在某台服务器上用文本编辑器维护 nginx 及 https 功能，而且一不小心就配错导致 `nginx restart` 不起来， html 的优点是 nginx 及 https 功能都在阿里云 CDN 中进行，只要在阿里云界面中鼠标点点就行。为了能方便使用阿里云中的 https 功能，此处记录 index.html 修改及相关阿里云配置方法。

原域名设为 `www.yourcompany.com` ，新增域名设为 `www.yc.com` 和 `yc.com` 。

## 只需进行一次的 index.html 修改
在 `www.yourcompany.com/index.html` 中添加如下内容
```
<html>
  <head>
...
    <script language="javascript">
        if (!(/yourcompany/i.test(location.hostname) || /localhost/i.test(location.hostname))) {
            location.replace(location.href.replace(location.hostname, 'www.yourcompany.com'));
        }
    </script>
...
  </head>
</html>
```

## 每新增一个域名后就需操作一次的阿里云配置
在 [域名服务](https://dc.console.aliyun.com) 中点击 `yc.com` 的 `SSL证书` 对 `www.yc.com` 域名进行申请。

在 [CDN](https://cdn.console.aliyun.com) 的 `域名管理` 中 `添加域名` ， `加速域名` 设为 `www.yc.com` ， `业务类型` 设为 `图片小文件` ， `源站类型` 设为 `www.yourcompany.com` 的 IP 地址和端口号。这里如果设为源站域名 `www.yourcompany.com` 则需要一天时间审核且可能被审核为“加速域名无法正常访问或内容不含有任何实质信息”而不被通过（然后可按 [域名准入标准](https://help.aliyun.com/document_detail/27114.html) 所述去开一个工单解决该问题）。如果 `www.yc.com` 未在政府机构备过案，则 CDN 会弹出对话框提示先去备案（备案申请通过需要至少一星期时间）。

在 [云解析DNS](https://dns.console.aliyun.com) 中点击 `yc.com` 的 `解析设置` ，在 `添加记录` 的对话框中， `记录类型` 选择 `CNAME` ， `主机记录` 为 `www` ， `记录值` 为上面 `域名管理` 中 `www.yc.com` 的 CNAME 。引申含义：结合上面 CDN 中的设置， CDN 说只有当传过来的域名为 `www.yc.com` 时才允许访问那个 CNAME ，以防止恶意网站经常过来蹭 CNAME ，然后 DNS 说我就是货真价实的 `www.yc.com` 。

在 [CDN](https://cdn.console.aliyun.com) 的 `域名管理` 中点击 `www.yc.com` 的 `配置` ，将 `回源host` 设置为 `www.yourcompany.com` 。引申含义：阿里云中的许多服务使用了 nginx ，阿里云界面中的相关设置与 nginx 配置其实是一一对应的，所以理解 nginx.conf 有助于理解阿里云界面中的设置，甚至可以进一步发现，当进行了阿里云中的一些设置后，自己 ECS 服务器中的一些 nginx 配置就用不着了；这个 `回源host` 其实就是对应着 nginx 配置中的 server_name ，所以如果你上面源站类型里的 `www.yourcompany.com` 的 IP 地址对应的 ECS 服务器中的 nginx 配置中只有一个 server 在监听 80 或 443 端口的，或者是 `www.yourcompany.com` 负载均衡的 IP 地址（或是 `www.yourcompany.com` 自身 CDN 的回源地址负载均衡的 IP 地址）对应的 [负载均衡](https://slb.console.aliyun.com) 实例的 `监听` 80 或 443 端口的 `添加转发策略` 中没有转发策略的（引申含义：负载均衡的设置也对应着 nginx 配置），那也可以不设置 `回源host` 。

上面操作之后， `http://www.yc.com` 就可以自动跳转到 `www.yourcompany.com` ，而为了让 `https://www.yc.com` 也可以自动跳转到 `www.yourcompany.com` ，还需在 [CDN](https://cdn.console.aliyun.com) 的 `域名管理` 中点击 `www.yc.com` 的 `配置` ，在 `HTTPS设置` 中选择前面申请的 SSL证书 。

因为 index.html 被加载后立即会跳转，所以 CDN 配置中的 `性能优化 | 智能压缩` 并非必须。

然后 `yc.com` 域名，除了与 `www.yc.com` 共用一个 SSL 证书所以不用再申请外，按照上面的步骤再操作一次即可，而不能简单地只做 `解析设置` 中 CNAME 到 `www.yc.com` 这一个步骤。引申含义： CDN 实际上内含着 nginx ， 这样我们就可以省去自己在 ECS 服务器中配置 nginx 的 server_name 和 https 所占用的金钱和时间了。
