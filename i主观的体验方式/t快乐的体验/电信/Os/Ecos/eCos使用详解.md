Li Zheng flyskywhy@gmail.com

# eCos 使用详解

## Profile

按照 eCos 文档[Profiling](http://ecos.sourceware.org/docs-latest/ref/gprof.html)中所说为 `.elf` 文件添加 Profile 功能后，使用 gdb 下载 `.elf` 文件并运行结束，即等待运行完成或是自己估摸着运行足够时间了，就在 gdb 中按下 `CTRL+C` ，然后就在 gdb 中运行如下两条命令：

    source ~/proj/ecos/Src/ecos/packages/services/profile/gprof/current/host/gprof.gdb
    gprof_dump

此时在电脑上当前目录下就会得到一个 `gmon.out` 文件。这是一个二进制文件，查看它的方法是使用 Linux 上默认自带的 gprof 程序，即在当前目录下（不是在 gdb 下）运行类似如下命令：

    gprof ecos_app_base.elf gmon.out -b

就会打印出相应的数据。
