Li Zheng flyskywhy@gmail.com

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
```
    listen <%= listen_address %>:<%= @listen_port %>
```
所以我们需要修改 `/etc/gitlab/gitlab.rb` 中的 `listen_port` ，然后实际上是把

    # nginx['listen_port'] = nil

修改为比如

    nginx['listen_port'] = 8788

`/etc/gitlab/gitlab.rb` 中默认用 HOSTNAME 来作为外部链接

    external_url 'http://SomeHostName'

这个外部链接将被用作比如用户注册确认邮件中的确认地址等 gitlab 基础功能，所以需要将其设置为浏览器可以访问到的地址，比如：
```
    external_url 'http://192.x.x.7:8788'
```
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
作为内部使用的 Git 仓库，安全是非常重要的，因此要及时用 root 账户进入比如 `http://192.x.x.7:8788/admin/application_settings` 进行分支保护程度、仓库可见程度、用户注册是否发送确认邮件等等默认全局设置。后续特定 Project 的分支保护程度和仓库可见程度可分别到 `Settings > Repository > Protected Branches` 和 ` Settings > General` 中去设置，比如纯文档类的仓库，就没必要进行 Merge Request 了，每个开发人员无需 Fork 到自己名下，而是直接在原仓库的 gitlab 网页上修改，这种情况下只要到 `Settings > Repository > Protected Branches` 中 `Unprotect` ，并且在 Group 的 `Members` 或 Project 的 `Settings > Members` 中显式地将允许修改的开发人员至少添加为 Developer 即可。

# 备份恢复迁移
参考了 [Gitlab配置、备份、升级、迁移](http://www.cnblogs.com/lidong94/p/7161717.html) 一文，备份方法是：

    sudo gitlab-rake gitlab:backup:create

其会在 `/var/opt/gitlab/backups` 目录下创建一个名称类似为 `1516244351_2018_01_18_9.3.2_gitlab_backup.tar` 的压缩包。

恢复方法例如：

    sudo gitlab-rake gitlab:backup:restore BACKUP=1516244351

迁移如同备份与恢复的步骤一样，只需要将老服务器 `/var/opt/gitlab/backups` 目录下的备份文件复制到新服务器上的 `/var/opt/gitlab/backups` 即可，但是需要注意的是新服务器上的 gitlab 的版本必须与创建备份时的 gitlab 版本号相同。

# 升级
gitlab 公司每个月 22 日都会发布升级包，参考 [Updating GitLab via omnibus-gitlab](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/update/README.md) 和 [Upgrading without downtime](https://docs.gitlab.com/ce/update/README.html#upgrading-without-downtime) ，只要安装 gitlab 时用的是 PostgreSQL ，然后每次只升级一个中间的 minor 版本号，比如从 gitlab 9.3.2 升级到 9.4.0 或是 9.4.7 之类的，而不是直接升级到 9.5.0，那么我们的 gitlab 就可以做到无需关停（当然在运行 `gitlab-ctl reconfigure` 的几十秒内会无法访问）就能升级。

在 [APT/YUM repository for GitLab Community Edition packages](https://packages.gitlab.com/gitlab/gitlab-ce) 上确认自己想升级的版本号，比如 9.4.0-ce.0 ，然后具体升级流程如下：

    sudo apt-get update
    sudo gitlab-rake gitlab:backup:create    # 进行备份操作，非必需
    sudo touch /etc/gitlab/skip-auto-migrations
    sudo apt-get install gitlab-ce=9.4.0-ce.0
    sudo SKIP_POST_DEPLOYMENT_MIGRATIONS=true gitlab-ctl reconfigure
    sudo gitlab-rake db:migrate

# 配置
gitlab-ce 内含了 redis 、 nginx 等等各种第三方软件包（被安装在 `/opt/gitlab/embedded/` ），可以按需在 `/etc/gitlab/gitlab.rb` 中进行配置，详见 [https://docs.gitlab.com/omnibus/settings/configuration.html](https://docs.gitlab.com/omnibus/settings/configuration.html) 。

由 [Checking for newer configuration options on upgrade](https://docs.gitlab.com/omnibus/package-information/README.html#checking-for-newer-configuration-options-on-upgrade) 可知，在首次安装 gitlab 时会自动生成 `/etc/gitlab/gitlab.rb` 文件，后续升级 gitlab 时则不会自动修改该文件，这是为了避免升级过程不小心覆盖用户配置。这样也是能正常运行升级后的 gitlab 的。可以通过 `sudo gitlab-ctl diff-config` 来查看自己的配置与原始版本 `/opt/gitlab/etc/gitlab.rb.template` 的区别，如果追求完美的，可以将两者手工合并为新的 `/etc/gitlab/gitlab.rb` 。

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

注：此时如果提示说 `mount.nfs: access denied by server while mounting 192.x.x.8:/pub/gitlab` ，则参考 [远程挂载NFS时mount.nfs: access denied by server while mounting 一个解决办法](https://blog.51cto.com/ydw1118/1728023) 中所说，需要在 nfs 服务端的 `/etc/exports` 中 no_wdelay 后面再添加一个 insecure 选项。

在**本地**启动 gitlab-ce 的运行

    sudo gitlab-ctl start

估计是远程 mount 的关系，此次 `sudo gitlab-ctl start` 后需要在浏览器上等待较长的二十秒钟左右才能自动结束 `Whoops, GitLab is taking too much time to respond` 的提示，而不要误以为是前面碰到的 8080 端口被占问题。

# 关停帐号
用 root 帐号可以关停用户帐号。有三种关停方式： `Block user` 、 `Remove user` 、 `Remove user and contributions` ，需要注意的是，记录在 PostgreSQL 中的 Snippets 会在后两种情况下消失。

# 持续集成 CI
让 gitlab 能够在新 commit （网页上直接修改文件内容而形成的 commit） 或 push 的事件时自动触发持续集成动作，有两个前提条件：将持续集成的具体动作比如“测试”、“部署”等 job 写在 Project 根目录中的 `.gitlab-ci.yml` 文件里；在 Project 的 gitlab 网页里配置好在另外一台服务器中运行的 Runner 以便让 Runner 去运行这些 job 。

如果在 commit 的注释中包含 `[ci skip]` 或 `[skip ci]` ，无论大小写，则该 commit 不会触发 CI 。

## 创建 .gitlab-ci.yml 文件
参照 [Getting started with GitLab CI](https://docs.gitlab.com/ce/ci/quick_start/README.html) 和 [Configuration of your jobs with .gitlab-ci.yml](https://docs.gitlab.com/ce/ci/yaml/README.html) 两篇文章，简单来说，除了 stages 、 cache 等关键字外，其它顶行书写的都是 job 。如果 job 中没有描述 stage 字段的，则这个 job 的 stage 默认为 test 。如果存在有 stages 的比如：

```
stages:
  - build
  - test
  - deploy
```
则首先并行执行完所有 stage 为 build 的 job ，如果这些 job 都成功了，就并行执行所有 stage 为 test 的 job ，以此类推。

job 中必须至少含有一个关键字 script 用来执行该 job 的动作，比如：
```
test_gitlab_ci:
  script:
    - npm install
```
为了避免经常让 npm 重新下载那些 node_modules ，可以添加 cache 关键字，比如：
```
cache:
  paths:
    - node_modules/
```
在 gitlab 的 Project 页面上有 `Set up CI` 按钮可以方便地直接跳转到 Repository 页面并且自动点击了 `+` 按钮、自动选择了 `.gitlab-ci.yml` 这个 Template ，只需要再人工选择一下 `Apply a GitLab CI Yaml template` 并进行修改即可。

`.gitlab-ci.yml` 的语法是否书写正确， 可以在 http://gitlab.your-company.com/ci/lint 中进行验证，而不用等到 Runner 报来错误再去修改。

### 下载 artifacts
job 中的 artifacts 关键字除了用于在 stages 之间传递中间产物之外，也可以被从 gitlab 网页上下载，这倒是方便了最终产物比如 `.apk` 文件的下载，详见 [Introduction to job artifacts](https://docs.gitlab.com/ce/user/project/pipelines/job_artifacts.html) 。注意，如果使用了 artifacts 关键字，则要记得在里面用上 expire_in 关键字比如 `expire_in: 1 week` 以免 artifacts 一直被保存在 gitlab 的用户数据里而占用越来越多的硬盘空间。

## 配置 Runner
Runner 最好是安装在与 Gitlab 不同的服务器上，因为 Runner 会消耗大量内存资源，而 Gitlab 如果没有足够内存的话会很卡顿。

Runner 分为两种：一个或多个 Project 特定使用的 specific Runner 以及 任何 Project 都能使用的 shared Runner 。

配置 Runner 时会用到 registration token ， specific Runner 的 token 是从 Project 的 `Settings ➔ Pipelines ` 页面上获取的， shared Runner 的 token 是从 root 账户的 admin/runners 页面上获取的。

按照 [Install GitLab Runner](http://docs.gitlab.com/runner/install/) 安装好 Runner ，然后在安装好 Runner 的服务器上进行配置，这里参考 [Registering Runners](http://docs.gitlab.com/runner/register/index.html) 以 Linux 为例描述一下配置过程：

    sudo gitlab-runner register

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com ):

    http://gitlab.your-company.com

Enter the token you obtained to register the Runner:

    输入上面提到的页面里获取的 token

Please enter the gitlab-ci description for this runner: 后续可在 gitlab 界面中修改

    [hostame]: 比如输入 192.x.x.9Shell 作为 runner 的描述，暗示会使用 192.x.x.9 上的 Shell 作为运行环境，或是 192.x.x.9Docker ，或是其它可以适当描述的字符

Please enter the gitlab-ci tags for this runner (comma separated): 可以为空，如果不为空或后续在 gitlab 界面中修改的话，则使得 `.gitlab-ci.yml` 中的某个 job 有了这样的能力 —— 如果 job 中存在 tag 关键字时那就只有相同 tag 的 Runner 才允许运行这个 job

Whether to run untagged jobs [true/false]: 如果上面一条不为空，则会出现此条，后续可在 gitlab 界面中修改

    [false]: 当 `.gitlab-ci.yml` 中的某个 job 中不存在 tag 关键字时，是否允许当前这个被上一条 tag 过的 Runner 运行这个 job

Whether to lock Runner to current project [true/false]: 后续可在 gitlab 界面中修改

    [false]: 后续在 gitlab 界面中修改使之按需（单向）转变为 specific Runner 即可

Registering runner... succeeded                     runner=上面 token 的前 8 个字符

Please enter the executor: docker-ssh, shell, virtualbox, kubernetes, docker, parallels, ssh, docker+machine, docker-ssh+machine:

    选择其中之一，常用的有 shell 或者是 docker ，可以输入 shell 并回车后， 当前的 Runner 就配置好了。

如果上一条输入的是 docker ，则还会出现下一条：

Please enter the Docker image (eg. ruby:2.1):

    可以输入某个合适的 docker 镜像名比如比较流行的体积很小的 alpine:latest 并回车后， 当前的 Runner 就配置好了。

此时，使用 `sudo gitlab-runner list` 命令就能看到已注册的 runner 列表了。更多命令使用方法详见 [GitLab Runner Commands](http://docs.gitlab.com/runner/commands/README.html) 。

[Executors](http://docs.gitlab.com/runner/executors/README.html) 中介绍了各个 excutor 的异同。

### Shell executor
Shell executor 相对其它 executor 来说比较容易理解和操作，在初期可以拿来熟悉 job 的运行方式。

在执行 job 的 script 中的命令时所需的各种依赖，比如 npm 命令本身需要安装到 /home/gitlab-runner 这个用户能够访问的路径中，可能比较麻烦，而且难以保证各个 Runner 上安装的各个软件的版本都相同，所以后期需要使用 Docker executor 。

### Docker executor
如果想用 Docker executor ，则在使用 Runner 之前请先安装 docker ：

curl -sSL https://get.docker.com/ | sh

至于实际使用的 docker 镜像，虽说可以在使用默认的比如 alpine:latest 或是 `.gitlab-ci.yml` 文件里指定的 image: node:latest 时，在  `.gitlab-ci.yml` 文件里另外安装一些必须的工具，就像下面做的那样：

```
before_script:
  - apt-get update -qq && apt-get install -qq rsync sshpass
```

但是 `apt-get` 有时也会碰到 `Could not resolve 'cdn-fastly.deb.debian.org'` 这样的网络问题，再考虑到 latest 所代表的意义是经常要从国内访问不太稳定的 DockerHub 上 pull 最新版本的镜像，所以最好是自己编译一个合适的特定版本镜像来长久使用，比如 [flyskywhy/java-nodejs:v8.3.0](https://hub.docker.com/r/flyskywhy/java-nodejs/tags/) 。

#### 为 Docker executor 配置 DNS
当然，严格来说，上面 `apt-get` 碰到的网络问题，与第一次使用 `Docker executor` 运行 job 时极可能会遇到的 `fatal: unable to access 'http://gitlab-ci-token:xxxxxxxxxxxxxxxxxxxx@gitlab.your-company.com/path/to/your/project.git/': Couldn't resolve host 'gitlab.your-company.com'` 属于同一个问题，解决方法是按照 [GitLab CI Runner Advanced configuration](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/blob/master/docs/configuration/advanced-configuration.md#the-runnersdocker-section) 中的描述，修改 `/etc/gitlab-runner/config.toml` 文件，在 `[runners.docker]` 小节中添加 `dns = ["114.114.114.114"]` ，或者是添加 `extra_hosts = ["gitlab.your-company.com:192.x.x.7"]` ，然后运行 `sudo gitlab-runner verify` 确认没有修改出错误，最后在 gitlab 上再次运行 job 即可。

#### 把容器提交为 docker 镜像
用 `docker run -i -t your-name/your-repo /bin/bash` 命令把镜像变成容器运行后，在其中进行了一些修改，就可以用 `docker commit` 命令将该容器转换成 docker 镜像。只不过这样的镜像只能被 docker 管理，如果需要同时也被 git 管理的，则可以使用下面的 Dockerfile 。

#### 从 Dockerfile 编译为 docker 镜像
##### 编写 Dockerfile
可以参考一些现有的 Dockerfile 比如 [docker-java-nodejs_Dockerfile](https://github.com/flyskywhy/docker-java-nodejs/blob/master/Dockerfile) 及 [Docker镜像构建文件Dockerfile及相关命令介绍](https://itbilu.com/linux/docker/VyhM5wPuz.html) 一文来编写适合自己项目的 Dockerfile 。

##### 手动从 Dockerfile 编译 docker 镜像
可以使用 `docker build -t your-name/your-repo:repo-tag .` 这样的命令来把当前目录中的 Dockerfile 编译成一个 docker 镜像（会被自动自动保存到 `/var/lib/docker/` 中），此时在 `.gitlab-ci.yml` 文件中写上 `image: your-name/your-repo:repo-tag` 后， Gitlab CI 就已经能使用该镜像了。后续还可以用 `docker push your-name/your-repo:repo-tag` 命令上传到 DockerHub 上。

##### 自动从 Dockerfile 编译 docker 镜像
还有更自动、方便的方法——让 DockerHub 自动把 GitHub 上的 Dockerfile 拉过去编译，我们只需要 `docker pull` 去使用镜像即可，这同时也避免了因为国内网络问题导致的 `docker build` 或 `docker push` 偶尔会失败几次。

自动编译 docker 镜像的方法是，按照 [Configure automated builds on Docker Hub](https://docs.docker.com/docker-hub/builds/#link-to-a-hosted-repository-service) 中所说，在登录后的 [Docker Hub](https://hub.docker.com) 网站的 `Profile > Settings > Linked Accounts & Services` 中选择 `Github` ，然后选择 `Public and Private` ，然后自动跳转到 GitHub 网站确认后，就可以在 DockerHub 网站的 `Create > Create Automated Build` 中选择包含 Dockerfile 的某个 GitHub repository 来创建可自动编译的 DockerHub repository 。今后只要在该 GitHub repository 中进行了 commit 或 push 的操作， DockerHub 就会自动编译出相应的 docker 镜像。

#### 为 Docker executor 配置缓存
`/etc/gitlab-runner/config.toml` 文件里 `[runners.docker]` 小节中默认存在

    volumes = ["/cache"]

的配置，既是说在容器之间需要缓存的数据是放在容器内的 /cache 卷中，具体对应宿主机上的位置则可以在容器运行时通过 `docker ps` 得到 `容器id` 再通过 `docker inspect 容器id` 得知：

    "/cache": "/var/lib/docker/volumes/08869e6d033a076de6c675e77c491f487434454d8a1939e8da36f803bab6a1ec/_data"

其中存放的实际上就是在 `.gitlab-ci.yml` 文件中所写的
```
cache:
  paths:
    - node_modules/

```
这个 `node_modules/` 会被自动压缩为 /cache/your-name/your-project/default/cache.zip ，并在下一个容器中解压缩，如此来实现 `.gitlab-ci.yml` 文件中的 `cache` 功能。

由于 docker 有自己的策略来决定何时删除那个 cache.zip ，为了避免偶尔可能因之让我们项目中的 `node_modules/` 重新去下载，同时为了完全避免每次在容器中下载 `~/.npm/` ，参考 [Optimizing Docker-Based CI Runners With Shared Package Caches](https://www.colinodell.com/blog/201704/optimizing-dockerbased-ci-runners-shared-package-caches) 一文，我们修改 `/etc/gitlab-runner/config.toml` 文件内容：

    volumes = ["/srv/cache:/cache:rw"]

并在 `.gitlab-ci.yml` 文件中编写如下内容：
```
before_script:
  - export YARN_CACHE_FOLDER=/cache/yarn
  - export NPM_CONFIG_CACHE=/cache/npm
  - export bower_storage__packages=/cache/bower
```
即可。

此种配置下用 `docker inspect 容器id` 就会看到：

    "/cache": "/srv/cache"

#### 一些 docker 常见错误的解决
如果 Gitlab 的 `Pipelines ➔ Jobs` 中的命令行打印出 `System error: open /sys/fs/cgroup/cpu,cpuacct/init.scope/system.slice/` 这样的错误，则需要：
```
sudo vi /lib/systemd/system/docker.service
...
[Service]
ExecStart=/usr/bin/docker -d -H fd:// --exec-opt native.cgroupdriver=cgroupfs
...

然后再通过如下方式来使能上述配置：
$ sudo systemctl daemon-reload
$ sudo service docker stop
$ sudo service docker start
```

如果 docker pull 时碰到 timeout ，那是因为墙引起的 DockerHub 网络不稳定，多试几次就好了，或者换到国内的源比如 DaoCloud ，或者直接按照 [How pull policies work](https://docs.gitlab.com/runner/executors/docker.html#how-pull-policies-work) 中所说，在 `/etc/gitlab-runner/config.toml` 文件里 `[runners.docker]` 小节中添加

    pull_policy = "never"

### VirtualBox executor
可以用来在虚拟机中的 macOS 中编译 iOS APP ，参见 [ReactNative项目中命令行编译iOS版的方法](../../编程语言/JavaScript/ReactNative项目中命令行编译iOS版的方法.md) 。实际使用中发现用 `Shell executor` 连接持续开启中的 macOS 虚拟机也是挺方便的。

### 将 Runner 运行在 docker 中
按照 [Run GitLab Runner in a container](http://docs.gitlab.com/runner/install/docker.html) 所说，如果你的项目的确有这个需求，你甚至能将 Runner 本身运行在 docker 中！

# 持续部署 CD
按照 [Introduction to environments and deployments](https://docs.gitlab.com/ce/ci/environments.html) 一文我们可以进行持续部署。

Project 的 `Pipelines ➔ Environments` 页面中的那个 `New environment` 不建议使用，而是在 job 中来建立。

在比如下面的 job 中：
```
deploy_staging:
  stage: deploy
  script:
    - echo "Deploy to staging server"
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - master
```
我们设定了 environment 是 staging ，这样当这个 job 被 Runner 执行后，我们就会在 Project 的 `Pipelines ➔ Environments` 中看到一个叫做 staging 的 environment 中的部署历史记录，在历史记录多于一个时，会看到旧的历史记录上的按钮变成了 Rollback ，如果网站足够简单就可以方便地点击该按钮进行部署回滚。

这里的 url 会在 gitlab 的许多网页中出现，当上面的 script 中比如用 rsync 命令真正地去部署后，这些网页中的这些 url 就能真正点击进入了。

一般在 rsync 中会用到部署目标服务器的用户名和密码，这些需要保密的变量名字需要设置在 `Settings ➔ Pipelines` 页面中的 `Secret variables` 处。在 `Settings ➔ Members` 中可以添加其它用户作为 Guest 、 Reporter 、 Developer 、 Master 中的某个角色，而除了 Master 以外，其它角色都不能访问 `Settings ➔ Pipelines` 页面。另外，如果担心 `Pipelines ➔ Jobs` 中的命令行打印信息透露一些细节，还可以在 `Settings ➔ Pipelines` 页面中去掉 `Public pipelines` 的勾选。

比如在 `Secret variables` 中添加了 DEPLOY_USER 和 DEPLOY_PASSWORD 之后，就可以如 [Variables](https://docs.gitlab.com/ce/ci/variables/README.html) 中所说，在 job 中的 script 里写成如下形式：
```
  script:
    - sshpass -p $DEPLOY_PASSWORD rsync -avuzq build/ -e 'ssh -oStrictHostKeyChecking=no' $DEPLOY_USER@112.113.114.115:~/your-project/
    - sshpass -p $DEPLOY_PASSWORD ssh -o StrictHostKeyChecking=no $DEPLOY_USER@112.113.114.115 ". .profile && cd ~/your-project/ && pm2 restart pm2.config.js"
```

## 直接编译为 docker 镜像并进行部署
目前业界有一种趋势：直接将应用代码编译为一个 docker 镜像，然后运行这个镜像中的应用代码的测试脚本，然后把这个测试通过的镜像 push 到（自己私有的） Docker Registry 中，最后把这个镜像从 Docker Registry 中部署到生产服务器上。不过正如 [Using Docker Build](https://docs.gitlab.com/ce/ci/docker/using_docker_build.html) 中所说，三种实现该目标的方法各有利弊，需要权衡选择。另外根据 [Spotify 的容器使用情况](http://www.linuxeden.com/a/9864) 中所说，如果使用这种方式，还需要承担 docker 自身可能出现的一些问题。总的来说，请根据项目实际需要，权衡是否选择此种部署方式。具体操作可以参考 [GitLab自动部署nodejs应用到阿里云Kubernetes集群中](GitLab自动部署nodejs应用到阿里云Kubernetes集群中.md) 一文。

# https
## 首次添加 SSL 证书
gitlab 默认是 http 的，如果想开启 https ，首先需要比如到 [阿里云免费申请免费SSL证书](http://www.cnblogs.com/joshua317/p/6179311.html) ，然后参考 [NGINX settings](https://docs.gitlab.com/omnibus/settings/nginx.html) 将获得的证书复制并重命名，比如：

    sudo mkdir -p /etc/gitlab/ssl
    sudo chmod 700 /etc/gitlab/ssl
    sudo cp 123456789012345.key /etc/gitlab/ssl/gitlab.your-company.com.key
    sudo cp 123456789012345.pem /etc/gitlab/ssl/gitlab.your-company.com.crt

再搜索并修改 `/etc/gitlab/gitlab.rb` 中相应的条目：

    external_url 'http://gitlab.your-company.com'
    nginx['redirect_http_to_https'] = true

最后 `sudo gitlab-ctl reconfigure` 即可。

最后的最后，如果之前配置过 Runner ，则还需到 Runner 的服务器上将 `/etc/gitlab-runner/config.toml` 文件里的 url 修改为 https 的并 `sudo gitlab-runner restart` 即可。

## 以后更新 SSL 证书
复制新证书到 `/etc/gitlab/ssl/` 后，执行

    sudo gitlab-ctl hup nginx

# npm install
如果托管在 gitlab 中的仓库想要被 `npm install` 安装，比如 `npm install git+https://gitlab.your-company.com/github/flyskywhy/react-web.git#5856028` ，则需要在 gitlab 网页上设置该仓库 `Settings | General | Project Visibility` 为 `Public` 。否则会报例如如下错误：

    npm ERR! fatal: Authentication failed for 'https://gitlab.your-company.com/github/flyskywhy/react-web.git/'

# 403 Forbidden
如果未经授权访问 gitlab 上的仓库超过默认的 10 次（ `/etc/gitlab/gitlab.rb` 中 maxretry 为 10 ），比如前述 `npm install` 出错超过 10 次，则会无法访问 gitlab 一小时。解决的方法是临时修改 `/etc/gitlab/gitlab.rb` 中的
```
# gitlab_rails['rack_attack_git_basic_auth'] = {
    # Rack Attack IP banning enabled
#   'enabled' => true,
    # Whitelist requests from 127.0.0.1 for web proxies (NGINX/Apache) with incorrect headers
#   'ip_whitelist' => ["127.0.0.1"],
    # Limit the number of Git HTTP authentication attempts per IP
#   'maxretry' => 10,
    # Reset the auth attempt counter per IP after 60 seconds
#   'findtime' => 60,
    # Ban an IP for one hour (3600s) after too many auth attempts
#   'bantime' => 3600
# }
```
为
```
 gitlab_rails['rack_attack_git_basic_auth'] = {
   'enabled' => false,
#   'ip_whitelist' => ["127.0.0.1"],
#   'maxretry' => 10,
#   'findtime' => 60,
#   'bantime' => 3600
 }
```
然后 `sudo gitlab-ctl reconfigure` ，确认可以访问 gitlab 了，再修改回来后 `sudo gitlab-ctl reconfigure` 即可。

## 一些 BUG 的解决方法
如果往 gitlab 上传了类似 Linux `kernel.git` 那种提交点特别多的仓库后（或是 gitlab 中 git 仓库越来越多？），出现 `git fsck` 进程占用 100% CPU 导致服务器卡死的问题，可以参考 [Git fsck memory leak (#3256) · Issues · GitLab.org](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/3256) 在 root 帐号登录 gitlab 后的 "Admin area" 的 "Settings" 页面里不勾选 `Enable Repository Checks` 。

如果发现有时 gitlay 进程占用 100% CPU ，可以参考 [High Gitaly CPU usage_load average causing issues (#42575) · Issues · GitLab.org](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/42575) 在运行 gitlab 的 Linux 服务器的 `/etc/security/limit.conf` 中添加
```
git soft nproc 10240
git hard nproc 10240
```
