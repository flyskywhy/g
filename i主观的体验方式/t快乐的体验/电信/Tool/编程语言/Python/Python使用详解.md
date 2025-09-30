Li Zheng flyskywhy@gmail.com

# Python 使用详解

## 从预编译包安装 Python
从 [https://github.com/indygreg/python-build-standalone](https://github.com/indygreg/python-build-standalone) 下载预编译好的安装包，以[cpython-3.11.10+20241016-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst](https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10+20241016-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst)为例

    cd /home/foobar/tools/
    wget https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10+20241016-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst
    tar axvf cpython-3.11.10+20241016-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst
    mv python cpython-3.11.10
    export PYTHONHOME=/home/foobar/tools/cpython-3.11.10/install
    export PYTHONPATH=/home/foobar/tools/cpython-3.11.10/install
    export PATH=/home/foobar/tools/cpython-3.11.10/install/bin:$PATH

## 从源码安装 Python
以期望运行 `https://github.com/Tianxiaomo/pytorch-YOLOv4/tool/darknet2pytorch.py` 为例，在 `git clone` 下来之后的 `pytorch-YOLOv4` 目录中直接运行

    python tool/darknet2pytorch.py

的话，会报错说

    ModuleNotFoundError: No module named 'torch'

显然是先要运行

    pip install -r requirements.txt

但运行到一半， `requirements.txt` 中的一个 module 会报错说当前运行的 python 版本太低，于是去 [https://www.python.org/downloads/](https://www.python.org/downloads/) 下载较新版本的 `Python 3.10.12` ，而该网站针对 Linux 只提供了源代码下载来自己编译安装，于是

    cd ~/tools/
    wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
    tar axvf Python-3.10.12.tgz
    cd Python-3.10.12
    ./configure
    make
    make test
    sudo make altinstall
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 100
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 150
    sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 200
    sudo update-alternatives --config python
    sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 100
    sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 150
    sudo update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.10 200
    sudo update-alternatives --config pip

编译过程中如果出现

    fatal error: pip_ffi.h: No such file or directory

则需要

    sudo apt install libffi-devel

并重新（最好先重新`./configure`）`make`

现在再次运行

    cd pytorch-YOLOv4
    pip install -r requirements.txt

如果出现错误

    Could not fetch URL

则需要先

    pip config set global.index-url https://mirrors.cloud.tencent.com/pypi/simple

（就会自动生成`~/.pip/pip.ini` 文件）来加以永久解决，或是在 `pip install` 后面临时加上参数

    -i https://mirrors.cloud.tencent.com/pypi/simple --trusted-host mirrors.cloud.tencent.com

如果出现错误

    pip is configured with locations that require TLS/SSL, however the ssl module in Python is not available

则可能是当前 Linux 中安装的 openssl 版本太旧而不符合太新版本的 `Python 3.10.12` 的需求，此时如果不想更新 openssl 版本的话，可以选择安装较旧版本的 `Python 3.6.2`

    cd ~/tools/
    wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz
    tar axvf Python-3.6.2.tgz
    cd Python-3.6.2
    ./configure
    make
    make test
    sudo make altinstall
    sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.6 250
    sudo update-alternatives --config python
    sudo update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.6 250
    sudo update-alternatives --config pip

然后如果仍然出现

    pip is configured with locations that require TLS/SSL, however the ssl module in Python is not available

的话，则可以观察一下之前 `make` 时最后的输出
```
    Failed to find the necessary bits to build these modules:
    _bsddb             _curses            _curses_panel
    _hashlib           _sqlite3           _ssl   <----------
```
如果有 `_ssl` 在里面的，则需要

    sudo apt install libssl-dev

并重新（最好先重新`./configure`）`make`

其它对应备忘

`_dbm`和`_gdbm`对应`sudo apt install libgdbm-dev libgdbm-compat-dev`

`_tkinter`对应`sudo apt install tk-dev`

`readline`对应`sudo apt install libreadline-dev`

如果出现错误

    ModuleNotFoundError: No module named '_bz2'

则需要

    sudo apt-get install libbz2-dev

并重新（最好先重新`./configure`）`make`

如果出现错误

    Exception:
    Traceback (most recent call last):
      File "/usr/local/lib/python3.6/site-packages/pip/_internal/cli/base_command.py", line 143, in main
    ...
    pip._vendor.pytoml.core.TomlError: /tmp/pip-install-5q3n6wai/cmake/pyproject.toml(87, 1): msg
    You are using pip version 18.1, however version 21.3.1 is available.
    You should consider upgrading via the 'pip install --upgrade pip' command.

则需要升级 pip 版本

    pip install --upgrade pip --user
    sudo update-alternatives --install /usr/bin/pip pip ~/.local/bin/pip3.6 300
    sudo update-alternatives --config pip

后续如果碰到

    ERROR: Could not find a version that satisfies the requirement

错误，升级 Python 也是一种解决方法，比如

    cd ~/tools/
    wget https://www.python.org/ftp/python/3.7.17/Python-3.7.17.tgz
    tar axvf Python-3.7.17.tgz
    cd Python-3.7.17
    ./configure
    make
    make test
    sudo make altinstall
    sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.7 350
    sudo update-alternatives --config python
    sudo update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.7 350
    sudo update-alternatives --config pip

## 坑

### `action='store_false'`

这个用于解决一个 PyTorch 问题的提交点 [https://github.com/flyskywhy/YOLOv5-Lite/commit/bb07475](https://github.com/flyskywhy/YOLOv5-Lite/commit/bb07475) 花了我几天时间去调试，然而究其原因只是 Python 的一个无聊设计——如果命令行参数被设计为 `action='store_false'` ，那就表示如果命令运行时没有写上该参数，则该命令就认为该参数为 `True` ，反之如果写上该参数，则反而为 `False` ——比较反人类的设计，很少有人会无聊到这样为自己的命令代码这样设计参数。

### `pip install` 时报错`no space left on device`也就是`/tmp/`存储空间不够

    mkdir /home/foobar/a-big-tmp
    TMPDIR=/home/foobar/a-big-tmp/ pip install -r requirements.txt
