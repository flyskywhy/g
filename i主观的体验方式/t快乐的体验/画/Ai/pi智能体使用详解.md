# pi 智能体使用详解

## 安装
[安装 Pi，并第一次打开它](https://pi.xiaomovps.com/guide/install-pi) 配合你自己常用的大模型 API 用起来，而且从该网站上的其它文章可以获知 Pi 是一个最小的智能体基座，任何人都可以基于它搭建专用智能体。比如可以方便地搭建一个移动端测试专用智能体，甚至都不用到网上搜寻现成的技能或扩展（然后我们再去适配），比如收费的 [https://www.skills.sh/lambdatest/agent-skills/appium-skill](https://www.skills.sh/lambdatest/agent-skills/appium-skill) 或是免费的 [https://github.com/full-stack-skills/testing-skills](https://github.com/full-stack-skills/testing-skills) 中的 appium 这个技能，而是直接用自然语言让 Pi 自己生成一个 appium 相关的 mcp 接口和技能等等，连 `AGENTS.md` 等都不用自己手动写，用两句中文“在本目录中创建相应的文件，以便在 pi coding agent 中使用 appium-mcp ，来用自然语言编写 Android 和 iOS 上的测试用例。如果需要安装相关软件比如 appium-mcp 的，请将安装方法写在 README.md 中”就搭建了包括 `AGENTS.md` 、 `README.md` 和技能等等在内的基本框架。

## QA

### 上下文空间一般顶多 1M ，而代码量极有可能远超过 1MB ，那 AI 如何能全面了解并修改代码？
从 AI 交互的 LOG 来看，是 AI 通过 grep 关键词来定位相关文件及行数，然后再 cat 或类似 `sed
 -n '270,290p' README.md` 来观察关键词相关代码。

### 出现 "Clipboard unavailable: install `wl-clipboard` (`wl-copy`) or chech Wayland access" 的提示是怎么回事？
在 Linux 中安装 wl-clipboard 包即可，比如 `sudo apt install wl-clipboard`
