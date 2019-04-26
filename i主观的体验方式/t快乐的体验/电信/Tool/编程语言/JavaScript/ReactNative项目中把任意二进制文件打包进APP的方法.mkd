Li Zheng <flyskywhy@gmail.com>

# React Native 项目中把任意二进制文件打包进 APP 的方法
基本思路是将二进制文件转换成 RN 打包工具能够认识的文件类型也就是 `node_modules/metro-bundler/src/defaults.js` 的 `assetExts[]` 中的那些后缀名。本文以 `.bmp` 为例。

## 生成特制 bmp 文件
首先使用图像软件生成一个仅一个像素的 head.bmp 文件，文件大小一般为 58 字节，然后使用如下命令将比如 firmwareV3.1.bin 的文件内容添加到 head.bmp 文件后面：

    cat head.bmp firmwareV3.1.bin > firmwareV3.1.bin.bmp

如此得到的 bmp 文件，既可以被图像软件打开，又可以在 58 字节后拥有所需的二进制数据。

## 读取二进制数据
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
