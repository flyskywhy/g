Li Zheng flyskywhy@gmail.com

# 制作 git 中心仓库的方法

## 服务器 192.168.1.7

    cd /pub/gittrees/
    mkdir apps
    chown lizheng:git apps
    chmod 2775 apps
    cd apps
    mkdir my_app.git
    chmod 2775 my_app.git
    cd my_app.git
    git init --bare --shared

## 客户端

    cd ~/proj/my_app
    git remote add origin lizheng@192.168.1.7:/pub/gittrees/apps/my_app.git
    git push origin master
