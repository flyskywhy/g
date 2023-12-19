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

PS: When update Profile in `./cfw`, the `~/.config/clash/profiles/1682300190771.yml` maybe updated, then you should do above again.

PS: You can use tmux to keep it running it even after close ssh terminal.

PS: [work with privoxy](https://github.com/flyskywhy/g/blob/master/i%E4%B8%BB%E8%A7%82%E7%9A%84%E4%BD%93%E9%AA%8C%E6%96%B9%E5%BC%8F/t%E5%BF%AB%E4%B9%90%E7%9A%84%E4%BD%93%E9%AA%8C/%E7%94%B5%E4%BF%A1/Os/Linux/Linux%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BB%B4%E6%8A%A4%E8%AF%A6%E8%A7%A3.md)

## to test in terminal

    curl -x clash_ip:8118 https://www.google.com
