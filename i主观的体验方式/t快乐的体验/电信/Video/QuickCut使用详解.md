Li Zheng <flyskywhy@gmail.com>

# QuickCut 使用详解
ffmpeg 是视频转码领域最好用的命令行工具， QuickCut 则是它最好用的的图形界面版本。

使用方法在 https://github.com/HaujetZhao/QuickCut 的 README.md 已经介绍得很详细了，这里稍微补充一些。

在 Linux 中使用

    sudo apt install portaudio19-dev
    pip3 install Quick-Cut

安装好 Quick-Cut 后，运行时如果在命令行终端中出现

    ModuleNotFoundError: No module named 'PyQt5.QtSql'

这样的错误，则还需要做如下操作

    sudo apt-get install python3-pyqt5.qtsql
