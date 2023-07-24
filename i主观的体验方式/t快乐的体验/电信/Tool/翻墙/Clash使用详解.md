# Clash 使用详解

## to run in ssh terminal
Run `./cfw` in `Clash Windows folder` and config it to works well, then

    cp ~/.config/clash/profiles/1682300190771.yml clash_shadowsocks.yaml

and edit `clash_shadowsocks.yaml` ref to `diff ~/.config/clash/profiles/1682300190771.yml ~/.config/clash/config.yaml` below:
```
1,3c1,4
< port: 7890
< socks-port: 7891
< allow-lan: false
< secret: ""
---
> mixed-port: 8118
> #port: 7890
> #socks-port: 7891
> allow-lan: true
> secret: YOUR-SECRET-COMES-FROM-SOMEWHERE
```
finally

    ./clash-linux-amd64-v1.15.1 -f clash_shadowsocks.yaml

PS: You can use tmux to keep it running it even after close ssh terminal.

## to test in terminal

    curl -x clash_ip:8118 https://www.google.com
