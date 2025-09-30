Li Zheng flyskywhy@gmail.com

# emsdk 使用详解
emsdk 可以将 C 代码编译为可以被 JS 调用的 WebAssembly 格式。

# 安装 emsdk

    cd ~/tools/
    git clone https://github.com/emscripten-core/emsdk.git
    cd emsdk
    ./emsdk install latest
    ./emsdk activate latest

# 使用 emsdk 编译出 `.js` 和 `.wasm`

    source ~/tools/emsdk_env.sh

手动修改比如 C++ 项目中的 Makefile ，使达到这样的意图

    CC=emcc AR=emar

如果 Makefile 本来可以编译出 `.so` 或 `.a` 文件的，则在 Makefile 中再多加如下语句就可以得到所需的 `.js` 文件

    emcc -O2 some.a -o some.js \
    -s TOTAL_MEMORY=314572800 \
    -s MODULARIZE=1 -s EXPORT_NAME=SomeCUtils \
    -s EXPORTED_FUNCTIONS='["_someCFunc"]' \
    -s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall"]'

最后进入 C++ 项目目录运行如下语句

    emmake make

即可。

如果 C++ 项目原来是用 configure 或 CMAKE 自动生成 Makefile 的，则参考 [Building Projects — Emscripten documentation](https://emscripten.org/docs/compiling/Building-Projects.html) 进行相应操作即可。

# 在 JS 中调用 `.js` 文件
可自行参考

* [FAQ — Emscripten documentation](https://emscripten.org/docs/getting_started/FAQ.html)
* [浏览器中执行 C 语言？WebAssembly 实践](https://zhuanlan.zhihu.com/p/101686085)
* [asm.js 和 Emscripten 入门教程 - 阮一峰的网络日志](https://www.ruanyifeng.com/blog/2017/09/asmjs_emscripten.html)
