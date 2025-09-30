Li Zheng flyskywhy@gmail.com

# PyTorch 使用详解

本文先介绍了一些 YOLO 模型在手机上的使用过程，再在“ YOLO 代码大致流程”一节中介绍了 PyTorch 的一些基本概念。

PyTorch 也可以用于训练其它深度学习模型，本文只介绍用于训练 YOLO 模型。

## 深度学习现状

深度学习的使用过程可以分为训练和部署两个阶段。

训练阶段是通过标注好各种物体位置和名称的大量旧照片训练（train）出模型文件也就是适合自己业务的权重（weight）文件。

部署阶段是在实际开展业务的设备上运行模型文件以推理（inference）识别出新照片中物体的位置和名称。

训练阶段所用的设备一般是安装有 GPU 的电脑，以让训练能够通过 GPU 将原本几小时的训练加速至几分钟。

部署阶段所用的设备一般是嵌入式设备或是 Android 设备或是电脑。

训练阶段所用的代码框架一般用的是 Meta 公司的 PyTorch ； Google 公司的 Tensor Flow 简称 TF 由于源代码质量不高以及其 1.0 和 2.0 版本 API 不兼容等原因，现已慢慢乏人使用；以及只用于 YOLO 模型的 [darknet](https://github.com/AlexeyAB/darknet)。

部署阶段所用的代码框架一般用的是 Meta 公司的 PlayTorch ，可以参考其在 <https://playtorch.dev/docs/tutorials/snacks/yolov5/> 中如何使用 `react-native-pytorch-core` ；如果追求 Android 手机上实时推理速度的，可以使用 <https://github.com/flyskywhy/YOLOv5-Lite> 和 <https://github.com/flyskywhy/Yolo-FastestV2> 所用的腾讯公司的 NCNN ；至于 Google 的 TF lite ，在部署上曾有先发优势，但由于源代码质量不高以及其 1.0 和 2.0 版本 API 不兼容等原因，现已慢慢乏人使用，不过如果用于 Web 的话可能还是需要 `tf.js` 。

另，标注是人工智能中的“人工”阶段，可以参考[深度学习图像标注工具汇总](https://blog.csdn.net/qq_34806812/article/details/81394646)和[LabelBee 让人工标注更智能](https://mp.weixin.qq.com/s/ii22i3dSauoSCmhLjNUo-w)。如果没有足够的照片而且目标尺寸较小使得在一张高分辨率照片中有许多目标，则也可以使用类似[在线图片水平_垂直均等切割工具](https://uutool.cn/img-incision/)来切割出几百张照片以进行训练。

## `react-native-pytorch-core` 与 `yolov5`

参考 [Python 使用详解](../Tool/编程语言/Python/PyTorch使用详解.md) 安装 Python 。

参考 [wrgb dataset](https://github.com/flyskywhy/wrgb) 数据集训练出 `yolov5s.ptl` 。

参考 <https://playtorch.dev/docs/tutorials/snacks/yolov5/> 在手机 APP 中使用 `yolov5s.ptl` 并在其中的

    await model.forward(formattedInputTensor)

前后加上 `console.time('detect');` 和 `console.timeEnd('detect');`，在其中的

    outputsToNMSPredictions()

前后加上 `console.time('NMS');` 和 `console.timeEnd('NMS');`，并将 `nMSLimit` 设为 200 ，此时在高通骁龙 888 上测得

    detect: 370ms
    NMS: 6300ms

注，如果上面在 `python export.py --weights runs/yolov5s_wrgb/exp/weights/best.pt --include torchscript` 时加上了参数 ` --img-size 416` ，则需要在 JS 代码中将 `const IMAGE_SIZE = 640` 改为 `const IMAGE_SIZE = 416` ，否则会出现诸如
```
{"message": "The size of tensor a (52) must match the size of tensor b (80) at non-singleton dimension 3

  Debug info for handle(s): debug_handles:{-1}, was not found.

Exception raised from infer_size_impl at /data/users/atalman/pytorch/aten/src/ATen/ExpandUtils.cpp:35 (most recent call first):
(no backtrace available)"}
```
或者
```
{"message": "shape '[1, 2, 60, 52, 52]' is invalid for input of size 768000"}
```
这样的错误（52x8=416 而 80x8=640），且 416 分辨率下测得 `detect: 150ms`

发现主要耗时在 detect 给出了 25200 个结果让 NMS 中的 for 循环做后处理，所以可以想办法使用 topk 只让 NMS 处理前 `nMSLimit = 200` 个预测值最大的结果，比如在 `outputsToNMSPredictions` 函数定义中
```
-  const rows = prediction.shape[0];
+  const indices = prediction.topk(nMSLimit, {
+    dim: 0,
+    largest: true,
+    sorted: true,
+  })[1];
+  const rows = indices.shape[0];
   const numberOfClass = prediction.shape[1] - 5;
   for (let i = 0; i < rows; i++) {
-    const outputs = prediction[i].data();
+    const indiceScoreSorted = indices[i][4];
+    const outputs = prediction[indiceScoreSorted].data();
```
以及
```
 function nonMaxSuppression(boxes, limit, threshold) {
+  // 之前已经用 prediction.topk 在 native 层排序过了，所以这里不再在 js 层排序了
   // Do an argsort on the confidence scores, from high to low.
-  const newBoxes = boxes.sort((a, b) => {
-    return a.score - b.score;
-  });
+  // const newBoxes = boxes.sort((a, b) => {
+  //   return a.score - b.score;
+  // });
+  const newBoxes = boxes;
```

此时测得

    detect: 370ms
    NMS: 140ms

总用时优化了 13 倍！

进一步测试可知 `outputsToNMSPredictions` 函数中的 for 循环里每 `prediction[indiceScoreSorted].data()` 一次就需耗时 1ms 左右，因此上面如果 `nMSLimit = 500` ，则就会测得 `NMS: 500ms` 左右，经分析还可以这样优化
```
-  const numberOfClass = prediction.shape[1] - 5;
+  const predictionLength = prediction.shape[1];
+  const numberOfClass = predictionLength - 5;
+  const indicesArray = indices.data();
+  const predictionsArray = prediction.data();
   for (let i = 0; i < rows; i++) {
-    const indiceScoreSorted = indices[i][4];
-    const outputs = prediction[indiceScoreSorted].data();
+    const indiceScoreSorted = indicesArray[i * predictionLength + 4];
+    const predictionPoint = indiceScoreSorted * predictionLength;
     // Only consider an object detected if it has a confidence score of over predictionThreshold
-    const score = outputs[4];
+    const score = predictionsArray[predictionPoint + 4];
     if (score > predictionThreshold) {
       // Find the detected objct calss with max score and get the classIndex
-      let max = outputs[5];
+      let max = predictionsArray[predictionPoint + 5];
       let classIndex = 0;
       for (let j = 0; j < numberOfClass; j++) {
-        if (outputs[j + 5] > max) {
-          max = outputs[j + 5];
+        if (predictionsArray[predictionPoint + j + 5] > max) {
+          max = predictionsArray[predictionPoint + j + 5];
           classIndex = j;
         }
       }

       // Calulate the bound of the detected object bounding box
-      const x = outputs[0];
-      const y = outputs[1];
-      const w = outputs[2];
-      const h = outputs[3];
+      const x = predictionsArray[predictionPoint];
+      const y = predictionsArray[predictionPoint + 1];
+      const w = predictionsArray[predictionPoint + 2];
+      const h = predictionsArray[predictionPoint + 3];

       const left = imgScaleX * (x - w / 2);
       const top = imgScaleY * (y - h / 2);
```

此时测得

    detect: 370ms
    NMS: 20ms

但还达不到视频实时检测的总用时需求 33ms

## `react-native-pytorch-core` 与 `yolov7`

继续优化性能。

参考 [wrgb dataset](https://github.com/flyskywhy/wrgb) 进行修改，

    git clone https://github.com/WongKinYiu/yolov7
    cd yolov7
    # Uncomment coremltools onnx onnx-simplifier in requirements.txt to run export.py
    pip install -r requirements.txt

将 `yolov7/models/yolov7-tiny.yaml` 复制为 `datasets/wrgb/yolov7-tiny.yaml` 并把其中的 `nc: 80` 改为 `nc: 4`

将 `datasets/wrgb/models/obj.yaml` 设为如下内容
```
train: ../datasets/wrgb/train.txt
val: ../datasets/wrgb/train.txt

nc: 4

names: [ 'w', 'r', 'g', 'b']
```
To train:

    # Download `yolov7-tiny.pt` from <https://github.com/WongKinYiu/yolov7/releases> as `cfg/training/yolov7-tiny.pt`

    rm ../datasets/wrgb/train.cache # If needed

    python train.py --epochs 55 --data ../datasets/wrgb/obj.yaml --cfg ../datasets/wrgb/yolov7-tiny.yaml --hyp data/hyp.scratch.tiny.yaml --weights cfg/training/yolov7-tiny.pt --img-size 416 --workers 4 --project runs/yolov7-tiny_wrgb --device cpu

To detect:

    python detect.py --weights runs/yolov7-tiny_wrgb/exp/weights/best.pt --img-size 416 --source SOME.jpg

To mobile optimized model exported to `runs/yolov7-tiny_wrgb/exp/weights/best.torchscript.ptl`:

    python export.py --weights runs/yolov7-tiny_wrgb/exp/weights/best.pt --grid --img-size 416
    cp runs/yolov7-tiny_wrgb/exp/weights/best.torchscript.ptl yolov7-tiny.ptl

得到 `yolov7-tiny.ptl` 。

测得

    detect: 130ms

推理用时优化了 3 倍！（但识别率下降较多）

但还达不到视频实时检测的总用时需求 33ms

## `react-native-pytorch-core` 与 `YOLOv5-Lite`

看看是否能如 [YOLOv5-Lite：更轻更快易于部署的YOLOv5](https://zhuanlan.zhihu.com/p/400545131) 所说那样训练出能在手机上实时识别的 `.ptl` 。

在通过 <https://github.com/flyskywhy/YOLOv5-Lite/commit/bb07475> 提交点解决了推理 `model.forward` 返回的数据格式问题后，参考 [wrgb dataset](https://github.com/flyskywhy/wrgb) 进行修改，

    git clone https://github.com/flyskywhy/YOLOv5-Lite
    cd YOLOv5-Lite
    pip install -r requirements.txt

将 `YOLOv5-Lite/models/v5Lite-e.yaml` 复制为 `datasets/wrgb/v5Lite-e.yaml` 并把其中的 `nc: 80` 改为 `nc: 4`

将 `datasets/wrgb/models/obj.yaml` 设为如下内容
```
train: ../datasets/wrgb/train.txt
val: ../datasets/wrgb/train.txt

nc: 4

names: [ 'w', 'r', 'g', 'b']
```
To train:

    # Download `v5lite-e.pt` from `Download Link` in `YOLOv5-Lite/README.md` as `models/v5lite-e.pt`

    rm ../datasets/wrgb/train.cache # If needed e.g. got `_pickle.UnpicklingError: STACK_GLOBAL requires str`

    python train.py --epochs 55 --data ../datasets/wrgb/obj.yaml --cfg ../datasets/wrgb/v5Lite-e.yaml --weights models/v5lite-e.pt --img-size 416 --workers 4 --batch-size 16 --project runs/yolov5Lite-e_wrgb --device cpu

To detect:

    python detect.py --weights runs/yolov5Lite-e_wrgb/exp/weights/best.pt --img-size 416 --source SOME.jpg

To mobile optimized model exported to `runs/yolov5Lite-e_wrgb/exp/weights/best.ptl`:

    python export.py --weights runs/yolov5Lite-e_wrgb/exp/weights/best.pt --grid --img-size 416
    cp runs/yolov5Lite-e_wrgb/exp/weights/best.ptl YOLOv5Lite-e.ptl

得到 `YOLOv5Lite-e.ptl` 。

测得

    detect: 110ms

接近但还达不到视频实时检测的总用时需求 33ms 以及 <https://github.com/ppogg/YOLOv5-Lite> 官网描述在 NCNN 中的 320x320 情况下的 27ms ，估计要移植 NCNN 到 react-native 才有可能。

但在手机上测得当 `conf_thres` 设为 0.3 时， `YOLOv5Lite-e.ptl` 检测到 0 个而 `yolov7-tiny.ptl` 检测到 100 个目标，且  `yolov7-tiny.ptl` 很有几个打分在 0.8 以上的，只有当 `conf_thres` 设为 0.1 时 `YOLOv5Lite-e.ptl` 才检测到聊聊几个目标。

所以 `YOLOv5Lite-e.ptl` 看起来并不合适，或者可以再尝试下非官方的 <https://github.com/bubbliiiing/yolov7-tiny-pytorch> 。

## `react-native-pytorch-core` 与 `Yolo-FastestV2`

继续优化性能。

参考 [wrgb dataset](https://github.com/flyskywhy/wrgb) 进行修改，

    git clone https://github.com/flyskywhy/Yolo-FastestV2
    cd Yolo-FastestV2
    pip install -r requirements.txt

参考 `Yolo-FastestV2/data/coco.data` 生成 `datasets/wrgb/obj-Yolo-FastestV2.data` 为如下内容
```
[name]
model_name=wrgb

[train-configure]
epochs=55
steps=150,250
batch_size=16
subdivisions=1
learning_rate=0.001

[model-configure]
pre_weights=None
classes=4
width=416
height=416
anchor_num=3
anchors=5.48,14.20, 13.54,14.93, 15.09,8.58, 16.81,16.89, 18.91,20.13, 23.56,24.22

[data-configure]
train=../datasets/wrgb/train-Yolo-FastestV2.txt
val=../datasets/wrgb/train-Yolo-FastestV2.txt
names=../datasets/wrgb/obj.names
```
这里的 `anchors=` 来源自 `python genanchors.py --traintxt ../datasets/wrgb/train-Yolo-FastestV2.txt` 所生成的 `Yolo-FastestV2/anchors6.txt`

这里的 `train-Yolo-FastestV2.txt` 复制自 `train.txt` 并将里面的相对路径替换为绝对路径。

To train:

    python train.py --data ../datasets/wrgb/obj-Yolo-FastestV2.data
    cp weights/best.torchscript.ptl Yolo-FastestV2.ptl

To detect:

    python test.py --data ../datasets/wrgb/obj-Yolo-FastestV2.data --weights weights/wrgb-50-epoch-0.862199ap-model.pth --img SOME.jpg

得到 `Yolo-FastestV2.ptl` 。

测得

    detect: 80ms

<https://github.com/dog-qiuqiu/Yolo-FastestV2> 官网自称使用 NCNN 在麒麟 990 上可以达到 detect: 5ms

由于其推理 `model.forward` 返回的数据格式与 `yolov5` 和 `yolov7` 等不同导致无法直接使用在现有 APP 代码中，所以暂时无法得知打分情况在手机上的高低。

## YOLO 代码大致流程

在解决 <https://github.com/flyskywhy/YOLOv5-Lite/commit/bb07475> 提交点所述问题时，通过加打印或删代码查看运行结果，大致了解了 YOLO 代码运行起来的关键节点，这里记录一下。

本文前面曾提及

    await model.forward(formattedInputTensor)

检测目标或者说“推理”这个动作为什么叫做 forward 呢？

在 `models/yolo.py` 中的 forward_once 函数中可以看到

    for m in self.model
        ...
        x = m(x)  # run

该文件中 `class Detect(nn.Module)` 拥有一个 forward 函数，在 `models/common.py` 文件中可以看到各个 class 比如 DWConvblock 也都各自拥有 forward 函数，然后在 `models/v5Lite-e.yaml` 中的 module 那一列可以看到分布着 Detect 和 DWConvblock 等引用，所以推想，并通过加打印或删代码查看运行结果加以验证的方式，可知：

* 某个 yaml 比如 `models/v5Lite-e.yaml` 被 `train.py` 训练出来的模型文件或者叫权重文件 `runs/yolov5Lite-e_wrgb/exp30/weights/best.pt` ，所对应的就是上面 forward_once 函数中的 `self.model`，体现着 `models/v5Lite-e.yaml` 文件中的内容
* 模型运行检测目标的功能或者叫推理，所对应的就是上面 forward_once 函数中的 `for m in self.model` 循环
* `models/v5Lite-e.yaml` 文件中的每一行或者叫网络中的每一层，所对应的就是上面 forward_once 函数中的 `for m in self.model` 中的 m
* 由 `models/v5Lite-e.yaml` 文件中的注释 `# [from, number, module, args]` 可以看出，每一行由 4 部分组成，其中 from 代表是从前 n 层获得的输入，如 -1 表示从前一层获得输入， number 表示网络模块的数目，如 `[-1, 3, C3, [128]]` 表示含有 3 个 C3 模块， module 和 args 分别对应着比如 `class Detect` 和 Detect 的 `__init__` 函数中的参数
* 上面 forward_once 函数中运行到 `m(x)` 时，其实就是在运行 `models/v5Lite-e.yaml` 文件中某一行的 module 比如 DWConvblock 的 forward 函数
* 当运行完最后一个 m ，一般来说就是运行到 `models/v5Lite-e.yaml` 文件中的最后一行比如 Detect 那一行时，手机上的 `react-native-pytorch-core` 所对应的就是 `await model.forward(formattedInputTensor)` 执行完毕，电脑上的 `detect.py` 所对应的就是 `model(img, augment=opt.augment)` 执行完毕
* 例外地，如果在 forward_once 函数运行前预先通过代码的方式为 `self.model` 额外添加了最后一层，那么该层 m 就没有对应到 `models/v5Lite-e.yaml` 文件中的最后一行了，比如在 `detect.py` 文件中的 `model(img, augment=opt.augment)` 代码之前添加代码 `model.nms(True)` 的话，那么 `model(img, augment=opt.augment)` 所返回的就不是 Detect 的结果，而是再之后的 NMS 的结果
* 可惜 `react-native-pytorch-core` 只暴露了 forward 方法而没有暴露 nms 方法，无法进行 `await model.nms(true)` 操作，导致耗时的 NMS 操作要用 JS 代码重写一遍并更耗时地运行
* 可惜 `yolov7` 在 `export.py` 文件中的 `model(img)` 代码之前添加代码 `model.nms(True)` 的话，在 `export.py` 导出时会出错，导致耗时的 NMS 操作要用 JS 代码重写一遍并更耗时地运行（注， `YOLOv5-Lite` 的 `export.py` 添加 `model.nms(True)` 不会出错，但如前所述 `YOLOv5-Lite` 打分太低，我没兴趣再测这个了）
* 可惜 yaml 文件中最后再添加一行 NMS 的方法，在 `train.py` 训练时会出错，导致耗时的 NMS 操作要用 JS 代码重写一遍并更耗时地运行
* 可以考虑直接在 Detect 中调用 `utils/general.py` 的 `non_max_suppression` 函数或其它你自己业务的后处理操作，毕竟 `yolov7/models/yolo.py` 的 Detect 中可是堂而皇之地存在着 `self.include_nms` 这个 nms 字眼可以作为示例，只不过 `self.include_nms` 所调用的 `self.convert(z)` 中的 `box @= convert_matrix` 只不过是做了 `non_max_suppression` 函数中的 `xywh2xyxy(x[:, :4])` 操作而已，另外，这样做的时候需要考虑使用下面提到的 `torch.jit.script` 而不是大部分 YOLO 的 git 仓库中 `export.py` 所用的 `torch.jit.trace`

## `export.py` 时需要注意的地方

如[Pytorch框架TorchScript模型转换方法](https://blog.csdn.net/cxx654/article/details/115916275)中所说，导出到 `.ptl` 时用到的 `torch.jit.trace` 是有一定限制的，因为 trace 方法不适用于 Module 中具有分支和循环结构的模型，可能需要自己想办法以 `torch.jit.script` 替代。

## 优化思路

### 更适合自己数据集的 anchor

参考[新手也能彻底搞懂的目标检测Anchor是什么？怎么科学设置？](https://zhuanlan.zhihu.com/p/112574936)将 anchor box 即锚点框或叫先验框调节为适合自己项目数据集中目标物体的大小，以显著提升自己项目在目标检测时的速度。

或许直接使用 <https://github.com/flyskywhy/Yolo-FastestV2> 中提供的 `genanchors.py` 来用 `python genanchors.py --traintxt ../datasets/wrgb/train-Yolo-FastestV2.txt` 自动生成 anchor 更合适。

### 网上看到的一些优化概念
精度换计算/内存/通信：

* 量化/用低精度计算：显而易见，如果你用Float16代替Float32，那么运行速度，需要的内存，需要的带宽基本上都可以直接砍一半
* 稀疏通信：精度换通信的一种做法：我们每次对梯度做all reduce的时候并不需要传所有梯度，只需要选择一部分（比如数值比较大）的梯度传输就好了
* 神经网络的各种剪枝：比如把很小的weight直接删掉，毕竟对最终结果没啥影响

参考 <https://openbayes.com/console/hyperai-tutorials/containers/2uN0r1tcWIj/overview> 进行 int8 quantization 量化？

参考阅读：

* [YOLOv5超详细的入门级教程（训练篇）——训练自己的数据集](https://mp.weixin.qq.com/s/IBZLLz0GV6E3EOeiJTMtjw)
* [Pytorch 数据流中常见Trick总结](https://mp.weixin.qq.com/s/QI_2AICgobdTvOktnL_UCg)
* [YOLO系列梳理（一）YOLOv1-YOLOv3](https://mp.weixin.qq.com/s/aVJQqeZyw0ljsBq1kElt_w)
* [YOLOv5：yolov5s.yaml配置文件解读](https://blog.51cto.com/u_15953612/6241978)
* [YOLOv5：解读yolo.py](https://blog.51cto.com/u_15953612/6316713)
* [Yolov5添加检测层，四层结构对小目标、密集场景更友好](https://blog.csdn.net/weixin_50006912/article/details/129122501)
* [理解矩阵乘法](https://www.ruanyifeng.com/blog/2015/09/matrix-multiplication.html)
* [常见问题汇总](https://github.com/bubbliiiing/yolov4-tiny-pytorch/blob/master/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E6%B1%87%E6%80%BB.md)
