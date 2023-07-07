Li Zheng <flyskywhy@gmail.com>

# Python 使用详解

## 安装 Python
以期望运行 `https://github.com/Tianxiaomo/pytorch-YOLOv4/tool/darknet2pytorch.py` 为例，在 `git clone` 下来之后的 `pytorch-YOLOv4` 目录中直接运行

    python tool/darknet2pytorch.py

的话，会报错说

    ModuleNotFoundError: No module named 'torch'

显然是先要运行

    pip install -r requirements.txt

但运行到一半， `requirements.txt` 中的一个 module 会报错说当前运行的 python 版本太低，于是去 <https://www.python.org/downloads/> 下载较新版本的 `Python 3.10.12` ，而该网站针对 Linux 只提供了源代码下载来自己编译安装，于是

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

现在再次运行

    cd pytorch-YOLOv4
    pip install -r requirements.txt

如果出现错误

    Could not fetch URL

则需要先

    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

（就会自动生成`~/.pip/pip.ini` 文件）来加以解决

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

    Failed to find the necessary bits to build these modules:
    _bsddb             _curses            _curses_panel
    _hashlib           _sqlite3           _ssl   <----------

如果有 `_ssl` 在里面的，则需要

    sudo apt install libssl-dev

并重新编译

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
