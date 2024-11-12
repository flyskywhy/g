# fastsdcpu 使用详解
[FastSD CPU](https://github.com/rupeshs/fastsdcpu)是一个可以在 CPU 上高速运行的 Stable Diffusion 版本，可部署在多种操作系统（甚至 Android ）上，这里以 Linux 为例。

## 安装
参考 [Python 使用详解](../../电信/Tool/编程语言/Python/Python使用详解.md) 安装 Python 3.9 或 3.10 或 3.11 等。

    sudo apt install git-lfs

    cd /home/foobar/
    git clone https://github.com/rupeshs/fastsdcpu
    cd fastsdcpu
    chmod +x *.sh
    TMPDIR=/home/foobar/a-big-tmp/ ./install.sh --disable-gui
    cd configs
    mkdir rupeshs
    cd rupeshs
    git clone https://hf-mirror.com/rupeshs/hypersd-sd1-5-1-step-lora
    cd ..
    mkdir Lykon
    cd Lykon
    git clone https://hf-mirror.com/Lykon/dreamshaper-8

将`fastsdcpu/configs/lcm-lora-models.txt`内的`rupeshs/hypersd-sd1-5-1-step-lora`替换为`/home/foobar/fastsdcpu/configs/rupeshs/hypersd-sd1-5-1-step-lora`。

将`fastsdcpu/configs/stable-diffusion-models.txt`内的`Lykon/dreamshaper-8`替换为`/home/foobar/fastsdcpu/configs/Lykon/dreamshaper-8`。

## 本地运行

    cd fastsdcpu
    ./start-webui.sh

## 本地生成图像
用浏览器打开<http://127.0.0.1:7860/>

在`Mode`中选择`LCM-LoRA`

在`Models`中，将`LCM LoRA model`设为`/home/foobar/fastsdcpu/configs/rupeshs/hypersd-sd1-5-1-step-lora`，将`LCM LoRA base model`设为`/home/foobar/fastsdcpu/configs/Lykon/dreamshaper-8`

在`Generation Settings`中，勾选`Use locally cached model or downloaded model folder(offline)`

在`Text to Image`中，填入提示词后点击`Generate`即可。

## API 运行
如果不希望在`fastsdcpu/results/`中保存图片的，需在`fastsdcpu/start-webserver.sh`中的`src/app.py --api`的后面多加个参数`--noimagesave`。

    cd fastsdcpu
    ./start-webserver.sh

## API 生成图像
用浏览器打开<http://127.0.0.1:8000/api/config>就可以看到之前`本地生成图像`一节中的设置，也就是自动生成的`fastsdcpu/configs/settings.yaml`中的内容。

由于每次调用`/api/generate`生成图像时都会自动修改`fastsdcpu/configs/settings.yaml`，而调用`/api/generate`时我们又不希望传入`/home/foobar/fastsdcpu/configs/rupeshs/hypersd-sd1-5-1-step-lora`这样的服务器上的绝对路径，所以需要将`fastsdcpu/src/backend/models/lcmdiffusion_setting.py`中`class LCMLora(BaseModel)`内的默认值修改为相应的绝对路径。

这样，将 fastsdcpu 部署到某台服务器后，就可以用类似下面的代码来生成图像

    const res = await axios({
      method: 'post',
      url: 'http://服务器IP地址:8000/api/generate',
      data: {
        prompt: 'YOUR AI PROMPT TEXT',
        use_offline_model: true,
        use_lcm_lora: true,
        image_height: 256,
        image_width: 256,
      },
      headers: {
        Accept: '*/*',
        'Content-Type': 'application/json',
      },
    });

生成的图像数据以 base64 字符串的形式在`res.data.images[0]`中体现，将该字符串加上前缀`data:image/png;base64,`粘帖到浏览器地址栏中，就可以直接查看了。

## 一些 BUG 的解决方法
### `ImportError: dlopen: cannot load any more object with static TLS`
如果碰到类似如下错误
```
  File "/home/foobar/fastsdcpu/env/lib/python3.9/site-packages/cv2/__init__.py", line 153, in bootstrap
    native_module = importlib.import_module("cv2")
  File "/home/foobar/cpython-3.9.20/install/lib/python3.9/importlib/__init__.py", line 127, in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
ImportError: dlopen: cannot load any more object with static TLS
```
则参考<https://github.com/pytorch/pytorch/issues/2575#issuecomment-2469427242>和<https://www.cnblogs.com/operaculus/p/12500510.html>，在`fastsdcpu/src/app.py`的第一行增加一句`import cv2`即可。

## 参考
[使用倚天CPU实例部署Stable Diffusion](https://help.aliyun.com/zh/ecs/deploy-stable-diffusion-on-yitian-instances)
