Li Zheng flyskywhy@gmail.com

# React Native 项目中把任意二进制文件打包进 APP 的方法
本文主要讲述把任意二进制文件打包进 APP 的方法，至于直接从 APP 运行时所在的操作系统中选择读取二进制文件的方法，则配合 [react-native-file-selector](https://github.com/prscX/react-native-file-selector) 使用 [rn-fetch-blob](https://github.com/joltup/rn-fetch-blob) 即可。

## 方法一、将二进制文件转换成数组
基本思路是将二进制文件转换成 JS 标准的数组，数组的每个元素是二进制文件一个字节的数字表示。

### 生成数组
首先安装将 `.bin` 文件转换成 `.c` 文件的工具：

    npm install -g bin2carray

然后在比如 `firmwareV3.1.bin` 文件所在的目录运行如下命令：

    bin2carray firmwareV3.1

最后将上面命令所生成的 firmwareV3.1.c 文件中的

    const unsigned char bin2carray_firmwareV3.1[64820] = {
    ...
    };

修改为

    export default [
    ...
    ];

并另存为 `firmwareV3.1.js` 即可。

### 读取二进制数据
```
actions.startOta({
    firmware: require('../images/firmware/firmwareV3.1.js').default
});
```

## 方法二、将二进制文件转换成图片
基本思路是将二进制文件转换成 RN 打包工具能够认识的文件类型也就是 `node_modules/metro-bundler/src/defaults.js` 的 `assetExts[]` 中的那些后缀名。本文以 `.bmp` 为例。

### 生成特制 bmp 文件
首先使用图像软件生成一个仅一个像素的 head.bmp 文件，文件大小一般为 58 字节，然后使用如下命令将比如 firmwareV3.1.bin 的文件内容添加到 head.bmp 文件后面：

    cat head.bmp firmwareV3.1.bin > firmwareV3.1.bin.bmp

如此得到的 bmp 文件，既可以被图像软件打开，又可以在 58 字节后拥有所需的二进制数据。

### 读取二进制数据
#### Development
使用 [jBinary Methods](https://github.com/jDataView/jBinary/wiki/jBinary-Methods) 可以读取指定偏移位置的数据，比如读取 4 个字符的版本号以及将二进制数据转换成字节数组以便进行 OTA 的两个函数：
```
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';
import jBinary from 'jbinary';

    getFirmwareFileVersion = () => {
        const head = resolveAssetSource(require('../images/firmware/head.bmp'));
        const headAddFw = resolveAssetSource(require('../images/firmware/firmwareV3.1.bin.bmp'));
        jBinary.loadData(head.uri).then(dataHead => {
            const headLength = dataHead.byteLength;
            jBinary.load(headAddFw.uri).then(dataHeadAddFw => {
                const versionOffset = 2;
                dataHeadAddFw.seek(headLength + versionOffset);

                console.warn(
                    dataHeadAddFw.read('char') +
                    dataHeadAddFw.read('char') +
                    dataHeadAddFw.read('char') +
                    dataHeadAddFw.read('char'));
            }, errHeadAddFw => {});
        }, errHead => {});
    }

    startOta = () => {
        const {
            actions,
        } = this.props;

        const head = resolveAssetSource(require('../images/firmware/head.bmp'));
        const headAddFw = resolveAssetSource(require('../images/firmware/firmwareV3.1.bin.bmp'));
        jBinary.loadData(head.uri).then(dataHead => {
            const headLength = dataHead.byteLength;
            jBinary.load(headAddFw.uri).then(dataHeadAddFw => {
                const firmware = dataHeadAddFw.read([
                    'array',
                    'uint8',
                    dataHeadAddFw.view.byteLength - headLength
                ], headLength);
                actions.startOta({
                    firmware
                });
            }, errHeadAddFw => {});
        }, errHead => {});
    }
```
#### Production
可参考 [How to read local images (Get base64 of local file)](https://stackoverflow.com/a/54594945/6318705) 中的 Production ，这里不再赘述。
