Li Zheng <flyskywhy@gmail.com>

# PyTorch 使用详解

参考 [Python 使用详解](../Tool/编程语言/Python/PyTorch使用详解.md) 安装 Python 。

参考 [wrgb dataset](https://github.com/flyskywhy/wrgb) 数据集训练出 `yolov5s.ptl` 。

参考 <https://playtorch.dev/docs/tutorials/snacks/yolov5/> 在手机 APP 中使用 `yolov5s.ptl` 并在其中的

await model.forward(formattedInputTensor)

前后加上 `console.time('detect');` 和 `console.timeEnd('detect');`，在其中的

outputsToNMSPredictions()

前后加上 `console.time('NMS');` 和 `console.timeEnd('NMS');`，并将 nMSLimit 设为 200 ，此时在 HUAWEI Mate Xs 2 上测得

    detect: 370ms
    NMS: 6300ms

发现主要耗时在 detect 给出了 25200 个结果让 NMS 中的 for 循环做后处理，所以可以想办法使用 topk 只让 NMS 处理前 200 个预测值最大的结果，比如在 outputsToNMSPredictions 函数定义中
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

此时测得

    detect: 370ms
    NMS: 140ms

总用时优化了 13 倍！

但还达不到视频实时检测的总用时需求 33ms

参考 [YOLOv5-Lite：更轻更快易于部署的YOLOv5](https://zhuanlan.zhihu.com/p/400545131) 以训练出能在手机上实时识别的 `.ptl` 。

阅读 [YOLO系列梳理（一）YOLOv1-YOLOv3](https://mp.weixin.qq.com/s/aVJQqeZyw0ljsBq1kElt_w) 以了解一些基本概念。

参考 [新手也能彻底搞懂的目标检测Anchor是什么？怎么科学设置？](https://zhuanlan.zhihu.com/p/112574936) 将 anchor box 即锚点框或叫先验框调节为适合自己项目数据集中目标物体的大小，以显著提升自己项目在目标检测时的速度。

精度换计算/内存/通信：

* 量化/用低精度计算：显而易见，如果你用Float16代替Float32，那么运行速度，需要的内存，需要的带宽基本上都可以直接砍一半
* 稀疏通信：精度换通信的一种做法：我们每次对梯度做all reduce的时候并不需要传所有梯度，只需要选择一部分（比如数值比较大）的梯度传输就好了
* 神经网络的各种剪枝：比如把很小的weight直接删掉，毕竟对最终结果没啥影响

参考阅读：

* [YOLOv5超详细的入门级教程（训练篇）——训练自己的数据集](https://mp.weixin.qq.com/s/IBZLLz0GV6E3EOeiJTMtjw)
* [Pytorch 数据流中常见Trick总结](https://mp.weixin.qq.com/s/QI_2AICgobdTvOktnL_UCg)