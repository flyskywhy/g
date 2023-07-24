Li Zheng <flyskywhy@gmail.com>

# Linux 其它

## `X11 connection rejected because of wrong authentication`
如果 `ssh -X` 远程登录过去启动图形应用程序比如 firefox 时报出此错误，可使用

    export XAUTHORITY=$HOME/.Xauthority

来解决。
