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

# 持续集成 CI
让 gitlab 能够在新 commit （网页上直接修改文件内容而形成的 commit） 或 push 的事件时自动触发持续集成动作，有两个前提条件：将持续集成的具体动作比如“测试”、“部署”等 job 写在 Project 根目录中的 `.gitlab-ci.yml` 文件里；在 Project 的 gitlab 网页里配置好在另外一台服务器中运行的 Runner 以便让 Runner 去运行这些 job 。

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

## Shell executor
Shell executor 相对其它 executor 来说比较容易理解和操作，在初期可以拿来熟悉 job 的运行方式。

在执行 job 的 script 中的命令时所需的各种依赖，比如 npm 命令本身需要安装到 /home/gitlab-runner 这个用户能够访问的路径中，可能比较麻烦，而且难以保证各个 Runner 上安装的各个软件的版本都相同，所以后期需要使用 Docker executor 。

## Docker executor
如果想用 Docker executor ，则在使用 Runner 之前请先安装 docker ：

curl -sSL https://get.docker.com/ | sh

至于实际使用的 docker 镜像，虽说可以在使用默认的比如 alpine:latest 或是 `.gitlab-ci.yml` 文件里指定的 image: node:latest 时，在  `.gitlab-ci.yml` 文件里另外安装一些必须的工具，就像下面做的那样：
```
before_script:
  - apt-get update -qq && apt-get install -qq rsync sshpass
```
但是 `apt-get` 有时也会碰到 `Could not resolve 'cdn-fastly.deb.debian.org'` 这样的网络问题，再考虑到 latest 所代表的意义是经常要从国内访问不太稳定的 DockerHub 上 pull 最新版本的镜像，所以最好是自己创建一个合适的特定版本镜像来长久使用。

### 一些 docker 常见错误的解决
如果 `Pipelines ➔ Jobs` 中的命令行打印出 `System error: open /sys/fs/cgroup/cpu,cpuacct/init.scope/system.slice/` 这样的错误，则需要：
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

如果 docker pull 时碰到 timeout ，那是因为墙引起的 DockerHub 网络不稳定，多试几次就好了，或者换到国内的源比如 DaoCloud

## VirtualBox executor
可以用来在虚拟机中的 macOS 中编译 iOS APP ？

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
    - sshpass -p $DEPLOY_PASSWORD rsync -avuz build/ -e 'ssh -oStrictHostKeyChecking=no' $DEPLOY_USER@112.113.114.115:/var/www/abc.your-company.com/
```
