Li Zheng <flyskywhy@gmail.com>

# Ali SmartLiving 使用详解

## 安装编译环境
由于 Ubuntu 用来编译 alios 的工具 aos 只能通过 python3 相关的组件 python3-pip 来安装，而 ali-smartliving-device-alios-things 中一些官方提供的 python 脚本仍然是 python2 语法的，所以需要如下罗嗦的方法来安装编译环境，而非仅仅只是安装 aos 即可。

### 安装 python 和 aos

    sudo apt-get install python2 python3 python3-pip
    pip3 install aos-cube

### 让 python 脚本运行在 python2 中
如果通过如下命令

    ls -l /usr/bin/python

发现

    /usr/bin/python -> python3

则

    cd /usr/bin
    sudo ln -f -s python2 python

否则编译时会出现 `NameError: name 'file' is not defined` 等错误。

### 让 aos 运行在 python3 中
用文本编辑器打开 `~/.local/bin/aos` ，确保第一行是 `#!/usr/bin/python3` 。

否则编译时会出现 `ImportError: No module named aos.__main__` 错误。

### 其它
我也曾想要通过简单将脚本从 python2 升级到 python3 语法来解决 `NameError: name 'file' is not defined` 等错误，但是又带来了其它语法问题，这已经不是我们而是 sdk 提供者需要再花时间在上面了，还是如上所述安装 python2 吧。之前听说 python 2 和 3 不兼容因而我一直拒绝深入学习使用 python ，果然 python 就是差劲啊，开源世界还不如将用到 python 的地方都切换为 nodejs 呢。

注，上述简单将 python2 的 `file` 改为 python3 的 `open` 后，还会出现如下报错信息：

    Traceback (most recent call last):
      File "tools/bk7231u/gen_firmware_img_uart0.py", line 39, in <module>
        pack_image(sys.argv[1], sys.argv[2])
      File "tools/bk7231u/gen_firmware_img_uart0.py", line 30, in pack_image
        f.write("\xff")
    TypeError: a bytes-like object is required, not 'str'

## 编译 Ali SmartLiving
参见 `ali-smartliving-device-alios-things/README.md` 中 `build.sh` 的使用方法。
