Li Zheng <flyskywhy@gmail.com>

# 安装
按照 [https://about.gitlab.com/downloads/](https://about.gitlab.com/downloads/) 中的 [https://mirror.tuna.tsinghua.edu.cn/help/gitlab-ce/](https://mirror.tuna.tsinghua.edu.cn/help/gitlab-ce/) 所说进行安装。

## 首次启动
使用 `sudo gitlab-ctl reconfigure` 来启动，首次启动时会打印出自动生成的各种配置文件的内容，可将之复制保存下来以备后用。

## 解决 80 端口被占问题
如果用浏览器打开 gitlab-ce 安装所在的主机的网页比如 192.x.x.7 时发现没有进入 gitlab 相关的正常或错误的界面，而是进入了其它页面，则说明之前 80 端口早已被占用，此时除了与其它程序共享 80 端口外，还可以将 gitlab 的端口进行调整。

### 与其它程序共享 80 端口
gitlab 用的 web 服务程序是 nginx ，如果占用 80 端口的其它程序也是 nginx 的，则可以共享之。

将原先的内含 `listen 80` 语句的比如 `/etc/nginx/sites-enabled/default` 文件移动为 `/etc/nginx/conf.d/default` ，然后将 `/etc/gitlab/gitlab.rb` 中的 `# nginx['custom_nginx_config'] = "include /etc/nginx/conf.d/example.conf;"` 修改为 `nginx['custom_nginx_config'] = "include /etc/nginx/conf.d/default;"`

`/etc/gitlab/gitlab.rb` 中默认用 HOSTNAME 来作为外部链接

    external_url 'http://SomeHostName'

这个外部链接将被用作比如用户注册确认邮件中的确认地址等 gitlab 基础功能，所以需要将其设置为浏览器可以访问到的地址，比如：

    external_url 'http://gitlab.your-company.com'

还需要在 DNS 提供商那里或是用户电脑操作系统的 hosts 文件中，将 `www.your-company.com` 和 `gitlab.your-company.com` 都指向同一个 IP 地址（ gitlab-ce 安装所在的主机）。

最后

    sudo service nginx restart
    sudo gitlab-ctl reconfigure

即可。

### 将 gitlab 的 80 端口进行调整
如果占用 80 端口的其它程序不是 nginx ，则只能调整 gitlab 的端口了。

从上面首次启动 `sudo gitlab-ctl reconfigure` 所打印出来的信息可以看到，有个 gitlab-http.conf 文件中含有

    listen *:80

这样的信息，然后使用 `grep gitlab-http.conf /opt/gitlab/* -rsi` 搜索一下会看到一个链接 [https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-cookbooks/gitlab/templates/default/nginx-gitlab-http.conf.erb](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-cookbooks/gitlab/templates/default/nginx-gitlab-http.conf.erb)，进去就会发现

    listen <%= listen_address %>:<%= @listen_port %>

所以我们需要修改 `/etc/gitlab/gitlab.rb` 中的 `listen_port` ，然后实际上是把

    # nginx['listen_port'] = nil

修改为比如

    nginx['listen_port'] = 8788

`/etc/gitlab/gitlab.rb` 中默认用 HOSTNAME 来作为外部链接

    external_url 'http://SomeHostName'

这个外部链接将被用作比如用户注册确认邮件中的确认地址等 gitlab 基础功能，所以需要将其设置为浏览器可以访问到的地址，比如：

    external_url 'http://192.x.x.7:8788'

最后 `sudo gitlab-ctl reconfigure` 即可。

## 解决 8080 端口被占问题
如果用浏览器打开 gitlab-ce 安装所在的主机的网页比如 192.x.x.7:8788 时发现所打开的 GitLab 网页出现 `Whoops, GitLab is taking too much time to respond` 的提示，一般是因为 8080 被占用了。

这个就比较简单了，把 `/etc/gitlab/gitlab.rb` 中搜索到的 `8080` 修改为比如 `8787` ，最后 `sudo gitlab-ctl reconfigure` 即可。

# 帐号
首次用浏览器打开 gitlab-ce 安装所在的主机的网页比如 192.x.x.7:8788 时，会进入一个修改密码的页面，此时修改的是 gitlab-ce 的 root 帐号的密码。然后就可以进行正常的用户注册登录等操作了。

# 邮件
在一些环节比如用户注册时是需要发邮件给用户的， gitlab-ce 一开始默认是使用 `/usr/sbin/sendmail` 来发送邮件，如果还不存在 sendmail 的话可安装 `sudo apt-get install postfix` 并配置好，或者是按照 [https://docs.gitlab.com/omnibus/settings/smtp.html](https://docs.gitlab.com/omnibus/settings/smtp.html) 来修改 `/etc/gitlab/gitlab.rb` 并 `sudo gitlab-ctl reconfigure` 使其生效。

## 邮件发送测试
邮件配置后需要测试是否配置正确。运行如下命令

    gitlab-rails console

稍等二十秒左右启动控制台后，在其中使用如下命令来测试邮件是否发送成功

    Notify.test_email('destination_email@address.com', 'Message Subject', 'Message Body').deliver_now

# 安全
作为内部使用的 Git 仓库，安全是非常重要的，因此要及时用 root 账户进入比如 [http://192.x.x.7:8788/admin/application_settings](http://192.x.x.7:8788/admin/application_settings) 进行仓库可见程度、用户注册是否发送确认邮件等等设置。

# 配置
由于 gitlab-ce 内含了 redis 、 nginx 等等各种第三方软件包（被安装在 `/opt/gitlab/embedded/` ），所以可以按需在 `/etc/gitlab/gitlab.rb` 中进行配置，详见 [https://docs.gitlab.com/omnibus/settings/configuration.html](https://docs.gitlab.com/omnibus/settings/configuration.html) 。由于 gitlab 每个月 22 日都会升级，所以每次升级后需要 `sudo gitlab-ctl diff-config` 看看是否有最新的配置需要人工添加到 `/etc/gitlab/gitlab.rb` 中。

# 启停
每次修改配置后，需要 `sudo gitlab-ctl reconfigure` 来启动。
如果想临时关闭（包括内含的 nginx 等等）的，则 `sudo gitlab-ctl stop` 来关闭所有或是比如 `sudo gitlab-ctl stop nginx` 来关闭其中一个。

# mount
对许多 Linux 系统来说，存放了用户数据的 /var/opt/gitlab/ 所在的 /var 是属于 / 分区的，一般而言 / 分区不会特别大，因此不停增长中的用户数据还是放在别的分区甚至别的电脑上更合适。一般使用 mount 来做到这一点。为保险起见，当使用 mount 时，可以在 `/etc/gitlab/gitlab.rb` 添加如下语句：

    # wait for /var/opt/gitlab to be mounted
    high_availability['mountpoint'] = '/var/opt/gitlab'

当然仅仅把 Git 仓库 `/var/opt/gitlab/git-data` 进行 mount 也是可以的。

最后 `sudo gitlab-ctl reconfigure` 即可。

## mount nfs
如果是远程 mount 的，经试验， sshfs 挂载的文件（夹）的权限无法满足 gitlab 的需求，所以只能用 nfs 。

在**本地**停止 gitlab-ce 的运行

     sudo gitlab-ctl stop

在**本地**把本地已经存在的用户数据复制到远程去

    sudo rsync -avuz /var/opt/gitlab/ -e ssh root@192.x.x.8:/pub/gitlab/

如果远程也存在一个叫 git 的账户的，上面的 rsync 操作会把本地上属于 git 用户/组 的文件（夹）自动转换成远程的 git 用户/组，因此还需在**远程**上执行如下操作以将它们再转换回本地 gitlab 所创建的 git 的 id 号 998 ：

    sudo find /pub/gitlab/ -group git -exec chgrp -h 998 {} \;
    sudo find /pub/gitlab/ -user git -exec chown -h 998 {} \;

在**远程**安装 nfs 服务端

    sudo apt-get install nfs-kernel-server

在**远程**配置 nfs 服务端

    sudo vi /etc/exports

填入如下内容

    /pub/gitlab *(rw,no_root_squash,sync,no_wdelay)

在**远程**重启 nfs 服务端

    sudo /etc/init.d/nfs restart

在**本地**安装 nfs 客户端

    sudo apt install nfs-common

在**本地** mount 远程的用户数据

    sudo mount -t nfs 192.x.x.8:/pub/gitlab /var/opt/gitlab

在**本地**启动 gitlab-ce 的运行

    sudo gitlab-ctl start

估计是远程 mount 的关系，此次 `sudo gitlab-ctl start` 后需要在浏览器上等待较长的二十秒钟左右才能自动结束 `Whoops, GitLab is taking too much time to respond` 的提示，而不要误以为是前面碰到的 8080 端口被占问题。

# 关停帐号
用 root 帐号可以关停用户帐号。有三种关停方式： `Block user` 、 `Remove user` 、 `Remove user and contributions` ，需要注意的是，记录在 PostgreSQL 中的 Snippets 会在后两种情况下消失。
