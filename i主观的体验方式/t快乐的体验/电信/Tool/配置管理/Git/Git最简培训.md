Li Zheng <flyskywhy@gmail.com>

# Git 最简培训
本文以 git 的图形界面进行培训，相比记忆各种 git 的终端命令，可以达到最简而仍能完成日常 git 操作。本培训不包含中心仓库的建立方法而只是使用方法。

在 Linux 终端或者 Windows 的 `D:\msysgit\msys.bat` 所打开的终端中，进入某个 git 管理的目录后，输入 `git gui`或者 `gitk --all` 命令，即可打开图形界面。只有打开着图形界面对照操作，培训才有效果。最好是自己找个测试目录进去 `git init` 然后随便折腾。

要做一个最简单的 Git 使用培训的话，除了说第一次要 `git clone` 或是 `git init` 一把，并且日常慢慢熟悉 `git gui` 图形界面中的菜单、按钮和 `gitk --all` 图形界面中的 `F2` 按键、各种按钮、分支名为粗体的是当前分支、分支名上的右键菜单、commit 注释上的右键菜单外，日常使用无非如下步骤：

1. 本地提交：本地新修改文件后，在 `git gui` 界面中，点击左上角“未缓存的改动”窗口中的文件图标，这些文件就会被挪入左下角“已缓存的改动”窗口，然后在右下角“提交描述”窗口中写一下这次提交的原因，最后就可以使用“提交”按钮将这些文件提交到本地 git 仓库中了。如果是第一次使用 git 进行提交，则提交前需先在 `git gui` 的菜单“编辑 | 选项”中右边的“全局”页面里填写“用户名”和“ Email 地址”。

2. 远端更新：在经过几次“提交”然后想要上传到中心 git 仓库时，因为只有在最新的代码基础之上的新提交点才能上传成功，所以先要确认自己的代码基础是否为最新。通过 `git gui` 的菜单“远端(remote) | fetch”操作，就可以将远端中心仓库上最新的代码拉过来。此时如果在 `gitk --all` 图形界面中发现自己新提交点的代码基础提交点位于 `remotes/` 分支比如 `remotes/origin/master` 分支之下，则需要合并当前分支到 `remotes/` 分支上。

3. 分支合并：合并分支有好几种方式，本文介绍最直观的 `Cherry-pick` 功能。这里以 `git fetch` 之后需要在 `remotes/` 分支上将当前分支合并过来作为例子，在 `gitk --all` 图形界面中，首先在 `remotes/` 提交点上用右键菜单“ Reset master branch to here ”把该提交点所在的 `remotes/` 分支同时也变成了当前分支，为避免歧义以及避免此时不小心关闭 `gitk --all` 界面后导致不再从属于任何分支的新提交点消失，这里需要在新提交点上用右键菜单“ Create new branch ”并命名为比如 `temp` 分支，然后将 `temp` 分支上与当前分支有差异的提交点从下往上按顺序一个个用右键菜单“ Cherry-pick this commit ”把它们像樱桃一样摘过来。如果在过程中提示有冲突的，则先使用 `git gui` 图形界面查看冲突所在并解决提交之，然后才进行下一个 `Cherry-pick` 操作。最后，在 `temp` 分支名上右键菜单“ Remove this branch ”即可。

4. 远端上传：在“上传”前，再次 `git fetch` 并确认为最新后，点击 `git gui` 界面上的“上传”按钮即可。

附：如果不想在 `git gui` 界面左上角“未缓存的改动”窗口中看到 `.o` 之类的文件，可以在 git 管理的目录中建立 `.gitignore` 文件并每行写入一种特征比如 `*.o` 。

另，针对 gitlab 或 github 进行 `git clone` 或 `git push` 操作时所需的密钥配置方法参见 [Ubuntu 22.04 SSH the RSA key isn't working since upgrading from 20.04](https://askubuntu.com/questions/1409105/ubuntu-22-04-ssh-the-rsa-key-isnt-working-since-upgrading-from-20-04) 运行

    ssh-keygen -t ed25519

后将生成的 `.pub` 文件中的内容粘帖到 gitlab 或 github 账户设置的 SSH key 那里。
