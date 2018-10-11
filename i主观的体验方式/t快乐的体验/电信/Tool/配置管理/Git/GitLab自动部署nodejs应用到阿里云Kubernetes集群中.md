Li Zheng <flyskywhy@gmail.com>

# gitlab 自动部署 nodejs 应用到阿里云 Kubernetes 集群中
使用 ECS 部署的基本步骤：将程序复制到 ECS 某个目录中然后发命令给 ECS 启动程序。

使用 K8S 部署的基本步骤：将程序制作为 docker 镜像并复制到阿里云镜像仓库中然后发命令给阿里云 Kubernetes 去取镜像并运行。

考虑到 gitlab 免费版 DevOps 自动部署模块最近新增的 Kubernetes 功能只支持一个 Kubernetes 集群，而任何版本的 gitlab 中对 Kubernetes 的一些额外支持如 Kubernetes 应用市场等功能，与商业收费的阿里云 Kubernetes 产品中的功能重复，所以抛开 gitlab 自带的 Kubernetes 功能，直接使用 kubectrl 命令行工具来连接 gitlab 自动部署脚本和阿里云 Kubernetes 产品的方法最为低耦合、低费用，这里低耦合的意思是在保证 CI/CD 基本流程不变的情况下，随时切换其中的 ECS 或 K8S 部署，参见下图：
```
                                                  负载均衡到 ECS 或 docker 中的
浏览器 <======> 阿里云 CDN 判断是否访问静态文件 <===n===> nginx 判断是否访问静态文件 <===n===> ECS 或 docker 中的后端进程
   ^                       |                             ^            ^                          ^
   |                      y|                             |           y|                          |
   |                       ⌄                             |            ⌄                          |
   =======y======= CDN 是否已有缓存 <===n===================     阿里云 OSS 中的前端文件 <=== 运行 gitlab 自动部署脚本
```
图中可以看到对于静态文件的判断，阿里云 CDN 和 nginx 是有重复操作的，后文会提到使用跨域访问来优化的方法。

## 在阿里云中开启容器仓库
如果是用阿里云子账号来操作容器仓库的，需要添加 [仓库访问控制](https://help.aliyun.com/document_detail/67992.html) 中描述的权限。

用阿里云主账号或子账号进入阿里云 [容器镜像服务](https://cr.console.aliyun.com/) 的镜像列表页面，点击“修改Registry登录密码”按钮，以创建今后使用 `docker login` 命令时的密码。

进入阿里云 [容器镜像服务](https://cr.console.aliyun.com/) 的命名空间管理页面，点击“创建命名空间”按钮，用公司名或人名作为命名空间，以便今后在比如阿里云容器 registry 的公网地址 `registry.cn-hangzhou.aliyuncs.com/你的命名空间/你的容器名称` 中与其他人的容器加以区分。

按 [镜像基本操作](https://help.aliyun.com/document_detail/60743.html) 中的描述 `docker login` 后，就可以开始 docker 其它操作了，详见下文。

## 用 docker 生成后端镜像
基本思路是在自动部署脚本中生成镜像，因为自动部署脚本一般在容器中执行，为了在 docker 容器中生成 docker 镜像，参考 [Using Docker-in-Docker for your CI or testing environment? Think twice.](http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) ，修改 `/etc/gitlab-runner/config.toml` 文件内容：

    volumes = ["/srv/cache:/cache:rw"， "/var/run/docker.sock:/var/run/docker.sock"]

这里 "/srv/cache:/cache:rw" 意义详见 [GitLab使用详解](GitLab使用详解.md) ， "/var/run/docker.sock:/var/run/docker.sock" 意义在于让 docker container 内运行的 docker-cli 命令能够使用 container 外的主机的 docker 环境。

在 gitlab 自动部署脚本 `.gitlab-ci.yml` 文件中编写如下内容（其中为了加快部署速度和加密 JS 源代码，使用了 [nodec](https://github.com/pmq20/node-packer) 来将 `index.js` `node_modules/` 等等编译为单独一个可执行文件，参见 [nodec 使用详解](../../编程语言/JavaScript/nodec使用详解.md)）：
```
image: flyskywhy/java-nodejs:v8.3.0

deploy-k8s-backend:
  stage: deploy
  cache:
    key: backend
    paths:
      - node_modules/
  tags:
    - docker # 下面的 nodec 需要 10GB 左右的内存和 10GB 左右的交换空间，所以这里使用了在足够内存和交换空间的电脑上的 tags 叫做 docker 的一个 Gitlab Runner 来运行此自动部署脚本
  before_script:
    - export NPM_CONFIG_CACHE=/cache/npm
    - rm -fr __tests__ android app index.android.js index.ios.js index.web.js ios # 删除后端运行时不需要的文件，以减小 nodec 最终生成的可执行文件大小
    - sed -i -e '/    "react/d' -e '/    "redux/d' -e '/    "rmc-/d' package.json # 去除前端依赖，以加快 npm update 速度
    - sed -i -e "s/^{.*/{\"gitSha\":\"`git rev-parse --short HEAD`\",/" package.json # 如果 nodejs 应用中想要 git 哈希值的话可以这样做，因为 nodec 最终生成的可执行文件内部是不包含 .git/ 的
    - npm update --production
    - npm run postinstall
  script:
    - /cache/opt/nodec -o nodeapp --skip-npm-install index.js 1>/dev/null 2>&1 # 将所有项目代码编译为一个可执行文件
    - /cache/opt/docker-cli login -u $ALIYUN_USER -p $ALIYUN_DOCKER_PWD registry.cn-shanghai.aliyuncs.com # 这里的 docker-cli 编译自 https://github.com/docker/cli
    - export DOCKER_IMAGE_NAME=registry.cn-shanghai.aliyuncs.com/你的命名空间/你的容器名称
    - /cache/opt/docker-cli rmi $DOCKER_IMAGE_NAME --force
    - /cache/opt/docker-cli build -t $DOCKER_IMAGE_NAME .
    - /cache/opt/docker-cli push $DOCKER_IMAGE_NAME:latest
  only:
    - k8s-backend
```
其中 `docker-cli push` 要注意的是，从 ECS 推送镜像时（比如你的 Gitlab Runner 运行在阿里云 ECS 中），可以选择走内网，速度将大大提升，并且将不会损耗您的公网流量。
* 如果您申请的机器是在经典网络，请使用 registry-internal.cn-shanghai.aliyuncs.com 作为registry的域名登录, 并作为镜像名空间前缀
* 如果您申请的机器是在vpc网络的，请使用 registry-vpc.cn-shanghai.aliyuncs.com 作为registry的域名登录, 并作为镜像名空间前缀

其中 `docker-cli build` 所默认调用的项目根目录中的 Dockerfile 内容如下：
```
FROM nginx:1.14 # 因为 19MB 的nginx:1.14-alpine 无法运行需要标准 glibc 的 node 程序，所以退而求其次选择了基于也算比较瘦小的 debian:stretch-slim 制作的 109MB 的 nginx:1.14

MAINTAINER Li Zheng <flyskywhy@gmail.com>

COPY nodeapp ./ # 这里是把前面用 nodec 生成的可执行文件复制到镜像中
COPY scripts/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8010 # 该值与 nginx.conf 中的 listen 对应
CMD nginx && ./nodeapp # nginx 被运行后会自动变成守护进程在后台运行，而基于必须要有一个程序在前台运行否则会自动关闭 docker 容器的概念，这里采用了在前台运行我们的 `node index.js` 应用或是被 nodec 生成的可执行文件的方法
```
其中 `nginx.conf` 的内容如下：
```
upstream be_upstream {
    server 127.0.0.1:1234 weight=7;
    keepalive 64;
}

server {
    listen 8010;

    #server_name www.YourProject.com # 这一行是不需要的，因为容器里显然最好只运行一项服务，所以没必要只监听（上面的 listen ）一个端口比如 80 然后通过本行来判断分流到不同服务（上面的某个 upstream）
    server_name 127.0.0.1;

    client_max_body_size 100m;

    if ( $uri = '/' ) {
        rewrite / /index.html last;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_next_upstream error timeout invalid_header http_500 http_503;

        proxy_pass http://be_upstream;
    }

    location ~* ^.+\.(html|htm|gif|jpg|jpeg|bmp|png|ico|txt|js|css|woff|woff2|eot|svg|ttf|mp4|avi|mov)$ {
        #proxy_pass http://YourProject-web-release.oss-cn-shanghai-internal.aliyuncs.com; # 生产环境时使用内部 oss 网址以节省 oss 流量
        proxy_pass http://YourProject-web-release.oss-cn-shanghai.aliyuncs.com; # 调试环境可能无法访问内部 oss 网址，所以需要此行

        # 主要缓存的是用户通过网页访问时的 react-web 打包的 index.html 和 bundle.js ，因此这里一般可以设置为发版的间隔时间
        expires 30d;
    }
}
```
上面 `nginx.conf` 起到了前后端分流的作用：对于后端的访问比如 `www.YourProject.com/api/some-api/` ，在经过后续会提到的 Kubernetes 部署后，进入了此处 `ip地址:8010` 里的 `nginx.conf` 中的 `location /` 而被分流向后端服务 nodeapp 开启的 1234 端口；同理，对于前端的访问比如 `www.YourProject.com` 最终会在 `nginx.conf` 中变成对 `/index.html` 的访问而被分流向保存着前端静态文件的网盘比如此处的 oss 地址。

参考 [Nginx Proxy_Pass to CDN vs hitting CDN directly. Pro's, Con's, Is it slower or are there negative effects on the server](https://stackoverflow.com/questions/9543068/nginx-proxy-pass-to-cdn-vs-hitting-cdn-directly-pros-cons-is-it-slower-or-a) 一文，为了避免前端静态文件从 oss 取出后还要流经占用 nginx 的资源来提供给浏览器，以及通过 CDN 来访问其回源的负载均衡提供的后端 API 性能相比直接通过负载均衡来访问会差 6 倍甚至可能会出错的问题，则可以抛开本文提供的前后端访问同一域名带来的无需考虑跨域访问 CORS 限制的好处，而另外再参考 [前端 CDN 网址跨域访问后端 nodejs 应用负载均衡网址的方法](前端CDN网址跨域访问后端nodejs应用负载均衡网址的方法.md) 一文。

## 部署前端静态文件到 OSS 中
前端静态文件由 gitlab 自动部署脚本 `.gitlab-ci.yml` 自动生成并上传到 OSS 中：
```
deploy-k8s-frontend:
  stage: deploy
  cache:
    key: frontend
    paths:
      - node_modules/
  tags:
    - docker
  script:
    - rm -f public/bundle.js public/index.html
    - npm run build-web # 这个命令参考自 https://github.com/flyskywhy/noder-react-native
    - if [ -f public/bundle.js ]; then true; else false; fi
    - export PROJ_GIT_HASH=`git rev-parse --short HEAD`
    - sed -i "s/bundle.js/bundle.js?v=$PROJ_GIT_HASH/" public/index.html
    - set +o pipefail
    - yes | /cache/opt/ossutil64 cp -r public/ oss://YourProject-web-release/ -e oss-cn-shanghai.aliyuncs.com
     -i $ALIYUN_OSS_ACCESSKEYID -k $ALIYUN_OSS_ACCESSKEYSECRET
    - set -o pipefail
  only:
    - k8s-frontend
```
还需对部署了前端文件的 OSS 进行配置：进入 [对象存储 OSS](https://oss.console.aliyun.com) 的 `YourProject-web-release` 的 `基础设置 | 静态页面` ，设置 `默认首页` 为 `index.html` ；如果不想让用户见到 OSS 提供的默认的代替 404 的网页 “This XML file does not appear to have any style information associated with it” ，则还可以设置 `默认 404 页` 。

## 部署后端镜像到 Kubernetes 中
阿里云 Kubernetes 的使用费用是比较昂贵的，因为无论是手动组建 Kubernetes 的这篇 [在阿里云上部署生产级别Kubernetes集群](https://www.kubernetes.org.cn/1667.html) 文章 ，还是在阿里云里购买 Kubernetes 时的自动配置，所需的 ECS （电脑主机）都至少是 3 台用于 Master 以及 1 台用于真正部署上百个 docker 容器的 Worker 。因为只用 1 台 Worker 体现不出来 Kubernetes 的意义，所以阿里云购买时的标配是 3Master+3Worker 。因为 Master 的配置在购买后无法更改，为了以后性能考虑，只能在购买时一步到位使用它默认的 `4核8G(ecs.n4.xlarge)` 配置。例如以 6 台 ECS 共 10元/小时 的费用来推算， 3Master+3Worker 的费用为 9万元/年 左右。从 [阿里云 Kubernetes VS 自建 Kubernetes](https://help.aliyun.com/document_detail/69575.html) 这篇文章可以看出， Kubernetes 的趋势是慢慢变成云服务商的一个产品，就像数据库、 CDN 等产品那样，因此自己购买 6 台服务器再请专业运维人员（10万/年？）创建、维护、升级 Kubernetes 的性价比低于直接使用阿里云 Kubernetes 。好消息是现在有比阿里云 Kubernetes 性价比更高的产品——阿里云 Serverless Kubernetes ——不用购买 ECS 而是按需付费。

### 阿里云 Kubernetes
[创建Kubernetes集群](https://help.aliyun.com/document_detail/53752.html) 时， Pod 和 Service 的网段可以参考如下设置：

Pod 网络 CIDR： 10.0.0.0/16 ，如此设置，就算类似 [管理专有网络](https://help.aliyun.com/document_detail) 那里那样存在有系统保留地址，也可以保证每个集群内最多可允许部署 256 台主机。

Service 网络 CIDR： 10.1.0.0/16 ，如此设置比较容易管理，今后如果创建第 2 个集群，那么它的 Pod 和 Service 就分别是

    10.2.0.0/16
    10.3.0.0/16

如果创建第 3 个集群，那就是

    10.4.0.0/16
    10.5.0.0/16

以此类推。

参考撰写 [deployment.yaml](https://code.aliyun.com/CodePipeline/nodejs-demo/blob/master/deployment.yaml) ，然后参考 [Kubernetes集群中使用阿里云 SLB 实现四层金丝雀发布](https://help.aliyun.com/document_detail/73980.html) 图形化部署在阿里云中的工作原理，再参考 [Connecting Applications with Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/) 、 [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) 、 [Services](https://kubernetes.io/docs/concepts/services-networking/service/) 这些文章编写适合自己项目的 `deployment.yaml` ，然后在自动部署脚本中配置好 [通过 kubectl 连接 Kubernetes 集群](https://help.aliyun.com/document_detail/53755.html) 后（配置的含义见 [配置对多集群的访问](https://kubernetes.io/cn/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) 一文），按照 [配置最佳实践](https://k8smeetup.github.io/docs/concepts/configuration/overview/) 所说用 `kubectl create -f ./deployment.yaml` 运行后端镜像，或是不使用 `deployment.yaml` 而是直接象 [Use a Service to Access an Application in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/) 那样用 `kubectl run` 、 `kubectl expose` 、 `kubectl set` 命令行来启动/更新 deployment 和 service （此处可参考 [Kubernetes kubectl 与 Docker 命令关系](http://docs.kubernetes.org.cn/70.html) 一文）。

### 阿里云 Serverless Kubernetes
在 [容器服务 - Kubernetes](https://cs.console.aliyun.com) 中 “创建Serverless Kubernetes” 后， [通过 kubectl 连接 Kubernetes 集群](https://help.aliyun.com/document_detail/71483.html) ，然后参考 [Serverless Kubernetes Examples](https://github.com/AliyunContainerService/serverless-k8s-examples) 编写适合自己项目的 `deployment.yaml` 。

[使用镜像创建应用](https://help.aliyun.com/document_detail/86383.html) 时的 `应用配置` 页面中的 `Init Container` 对应 yaml 写法见 [Init 容器](https://kubernetes.io/cn/docs/concepts/workloads/pods/init-containers/) ； `存活检查` 和 `就绪检查` 对应 yaml 写法见 [Pod 的生命周期](https://kubernetes.io/cn/docs/concepts/workloads/pods/pod-lifecycle/) 。

由于更新 service 时会出现 `spec.clusterIP: Invalid value: "": field is immutable` 这个已知 k8s 的 BUG ，所以将 `deployment.yaml` 拆分为 deploy.yaml 和 svc.yaml 会更方便。

示例 deploy.yaml 如下：
```
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      # 如果使用的是阿里云以外的私有容器镜像仓库，则需要 imagePullSecrets ，此处 `docker-registrykey-私有容器镜像仓库`
      # 来自于命令 `kubectl create secret docker-registry docker-registrykey-私有容器镜像仓库 --docker-server=私有容器镜像仓库地址 --docker-username=私有容器镜像仓库用户名 --docker-password=私有容器镜像仓库密码`
      # imagePullSecrets:
      #   - name: docker-registrykey-私有容器
      containers:
        - name: nginx
          image: registry-vpc.cn-shanghai.aliyuncs.com/你的命名空间/私有容器镜像:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 80
          # 注意，如果直接在阿里云控制台容器服务更新“部署”会导致环境变量为空
          # env:
          #   - name: DEMO_GREETING
          #     value: "Hello from the environment"
          #   - name: NODE_ENV
          #     valueFrom:
          #       configMapKeyRef:
          #         name: config-some
          #         key: NODE_ENV
          #   - name: SERVER_PORT
          #     valueFrom:
          #       secretKeyRef:
          #         name: secret-some
          #         key: SERVER_PORT
          envFrom:
            - configMapRef:
                name: config-some
            - secretRef:
                name: secret-some
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-autoscaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1beta2
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: memory
      targetAverageUtilization: 50
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 50
  - type: Pods
    pods:
      metricName: packets-per-second
      targetAverageValue: 1k
```
上面的 `nginx-autoscaler` 参考自 [Pod水平自动伸缩（Horizontal Pod Autoscaling）演练](https://k8smeetup.github.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) 及 [K8S集群基于heapster的HPA测试](http://blog.51cto.com/ylw6006/2113848) 。

示例 svc.yaml 如下：

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  annotations:
    # service.beta.kubernetes.io/alicloud-loadbalancer-protocol-port: "http:80"

    # 在阿里云“SSL证书”中购买证书后推送到负载均衡，然后在负载均衡页面的证书管理中可以得到下面所需的证书ID
    service.beta.kubernetes.io/alicloud-loadbalancer-cert-id: ${证书ID}
    service.beta.kubernetes.io/alicloud-loadbalancer-protocol-port: "https:443"

    # 先注释掉本行注解后 kubectl create 创建一个新 SLB 实例，然后为了避免今后 kubectl replace --force
    # 或 kubectl delete 时自动删除该 SLB 实例，需要到阿里云控制台负载均衡页面将该 SLB 的“名称”修改掉，
    # 将“标签”删除掉，然后 kubectl delete 时就不会删除该 SLB 实例了。
    # 最后，为了后续一直使用该新建的 SLB 实例比如 lb-bp1hfycf39bbeb019pg7m ，就再同时开启使用下面的注解
    # service.beta.kubernetes.io/alicloud-loadbalancer-id: lb-bp1hfycf39bbeb019pg7m
spec:
  ports:
    - port: 80
      name: http-port
      targetPort: 80
      protocol: TCP
    - port: 443
      name: https-port
      targetPort: 80
      protocol: TCP
  selector:
    app: nginx
  type: LoadBalancer
```
在唯一一次手工 `kubectl create -f svc.yaml` 创建一个新 SLB 实例后就按 `svc.yaml` 中的注释修改该文件以给自动部署脚本调用了。

## 让其他阿里云产品能够访问 Kubernetes pod
把专有网络 VPC（Virtual Private Cloud）的 [路由表](https://vpcnext.console.aliyun.com/vpc/cn-shanghai/route-tables) 中的 `目标网段` 添加到相关阿里云产品比如 [云数据库RDS](https://rdsnext.console.aliyun.com) 、 [云数据库MongoDB](https://mongodb.console.aliyun.com) 等等的白名单中，这样使用着 VPC 地址的 pod 就可以正常访问这些产品了。

## 让 Kubernetes pod 能够访问外网
如果想让 pod 能够访问外网，需要开通 [NAT网关](https://vpcnext.console.aliyun.com/nat/cn-shanghai/nats) ，并购买一个 [弹性公网IP](https://ip.console.aliyun.com) 绑定到 NAT 的 SNAT 上。

## log
从这篇文章 [全面提升，阿里云Docker/Kubernetes(K8S) 日志解决方案与选型对比](https://blog.csdn.net/zhoushuntian/article/details/79400747) 看，阿里云 logtail 产品 [日志服务](https://sls.console.aliyun.com)比 logstash 更适合 k8s 容器环境，而且这样就不用费心去做含有 rsyslogd 程序的 docker 镜像了。

本文主要讲解 Serverless Kubernetes 的 log 方法。

### 阿里云 Kubernetes 的 log
详阅 [Kubernetes日志采集](https://help.aliyun.com/document_detail/66654.html) ，这里不再赘述。

### 阿里云 Serverless Kubernetes 的 log
因为经阿里云客服工单核实，阿里云日志服务不支持采集 Serverless Kubernetes 的[容器-标准输出](https://help.aliyun.com/document_detail/66658.html)，所以这里只能记录下 [通过阿里云日志服务采集日志](https://help.aliyun.com/document_detail/71502.html) 对文本 [采集方式](https://help.aliyun.com/document_detail/28981.html) 的实践过程。

步骤 1 [操作Project](https://help.aliyun.com/document_detail/48984.html) 创建 YourProject 项目。

步骤 2 [操作Logstore](https://help.aliyun.com/document_detail/48990.html) 创建 dev-access 日志库。

步骤 3 以机器组名称 dev [创建机器组](https://help.aliyun.com/document_detail/28966.html) ，并将用户自定义标识设为 YourProject-dev ，该用户自定义标识后面将会被配置到 YAML 环境变量 ALIYUN_LOGTAIL_USER_DEFINED_ID 中。

步骤 4 创建 Logtail 配置，数据类型选择 `Docker文件` ；下一步，配置名称填写 `dev-access` ，日志路径填写 `/ecilogs` 和 `access.log` ，模式可以先选择 `极简模式` 使得日志内容展示原始的一行 log ，如果你的 log 是 JSON 格式的话，稍后可以再回来修改为 `JSON模式` ，然后你就会看到新的日志内容变成了多行的 kev-value 格式；下一步，应用到 dev 机器组。

步骤 5 在上面的 deploy.yaml 中的 spec.template.spec 里修改为如下配置：
```
      containers:
        - name: ilogtail
          image: registry.cn-hangzhou.aliyuncs.com/acs/ilogtail:0.13.4-eb42407
          env:
            - name: ALIYUN_REGION_ID
              value: ${https://help.aliyun.com/document_detail/40654.html 中描述的 k8s 集群所在的地域ID}
            - name: ALIYUN_LOGTAIL_USER_ID
              value: "${https://account.console.aliyun.com 中所示的阿里云账号ID（不是账号名，而且因为ID是一串数字，而这里需要的是字符串，所以记得加双引号）}"
            - name: ALIYUN_LOGTAIL_USER_DEFINED_ID
              value: YourProject-dev
          volumeMounts:
            - name: app-log
              mountPath: /ecilogs
              readOnly: true
        - name: nginx
...
            - secretRef:
                name: secret-some
          volumeMounts:
            - name: app-log
              mountPath: /log
      volumes:
        - name: app-log
          emptyDir: {}

```

现在，在日志库中点击 dev-access 的 `查询` ，就可以看到日志内容了。
