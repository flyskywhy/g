Li Zheng flyskywhy@gmail.com

# 将已有的 Markdown 文档 Git 仓库自动转为网页并托管为网站
本文以 [https://github.com/flyskywhy/g](https://github.com/flyskywhy/g) 作为已有的 Markdown 文档 Git 仓库的例子。

已有的 Markdown 文档 Git 仓库是将 docusaurus 安装在子目录 `website/` 中，如果是新建 Git 仓库，则也可选择将 docusaurus 安装在根目录中，则下文中与 `website/` 相关的地方都可以简化。

## 使用 docusaurus 手动生成网页
### 安装 docusaurus
```
git clone https://github.com/flyskywhy/g
cd g
npx create-docusaurus@latest website classic
```
然后将 website 目录进行 git 提交，参见 [docusaurus: just npx create-docusaurus with @docusaurus/core@3.9.1](https://github.com/flyskywhy/g/commit/d47d2af3489d1900c068ba701e6889daae20eaf2) 。

### `npm start` 预览调试环境网页
在 `npm start` 之前先把所有文档移动到唯一一个目录中，然后进行在 `website/docusaurus.config.js` 中设置 `path` 等操作，参见 [docusaurus: can debug flyskywhy website with `./pre-website.sh; cd website; npm start` and `./post-website.sh`](https://github.com/flyskywhy/g/commit/c998c95ce89054a383e991002865c47be5da4dad) 。

运行过程中可能会遇到你的 md 文档中有些写法不符合 docusaurus 所用的 mdx 语法的问题，比如 `@` `%` `/` `-` 字符不能跟在 `<` 之后，参见

* [docusaurus: fix plain text email address can not after `<` in MDX, to fix Error: MDX compilation failed for file "some.md" Cause: Unexpected character `@` (U+0040) in name](https://github.com/flyskywhy/g/commit/c81bdce006571fe668fe9cc1039d883164c54618)
* [docusaurus: fix plain text @ % / - can not after < in MDX](https://github.com/flyskywhy/g/commit/30ba6a8b610cf56243edcc83e534a1f998160166)
* [docusaurus: fix plain text can not after `{` in MDX](https://github.com/flyskywhy/g/commit/9b448690027682bcd9f576ecd7f72189270bbd08)
* [docusaurus: fix plain http example (Can't parse URL) can not be in MDX](https://github.com/flyskywhy/g/commit/40b114a9c0bd7d1ae908a8fdd4d89f10be7963a9)

另，目录名或文件名中不要含有空格。

### `npm run build` 生成生产环境网页
在 `npm run build` 之前先修改 `website/docusaurus.config.js` 中的 `url` 和 `baseUrl` ，就可以生成后续 gh-pages 分支所需的网页了，参见 [docusaurus: can build flyskywhy website with ./build-website.sh](https://github.com/flyskywhy/g/commit/a5f73c754a122ecc43e0ce052cc41d4c24c71709) 。

还可以使用 `npm run serve` 预览生成在 `website/build/` 中的网页。

运行过程中可能会遇到你的 md 文档中有些写法不符合 docusaurus 所用的 mdx 语法的问题，解决方法参见

* [docusaurus: fix plain text can not after `{` in MDX when npm run build](https://github.com/flyskywhy/g/commit/9a274c682c1df6c7e1c9099b11096eaa11d59bce)
* [docusaurus: fix url link without https// header will Broken link on source page in MDX when npm run build](https://github.com/flyskywhy/g/commit/076351d2848ec0025e953c490b008f894304a99b)

## 将网页上传到 gh-pages 分支以自动托管为网站
先生成一个独立于任何现有分支的 `gh-pages` 分支
```
git checkout --orphan gh-pages
```
然后将 `website/build/` 移动到 Git 仓库外的某个临时目录中，再将除 `.git` 外的所有文件删除，再将刚才移出的 `website/build/` 目录中的所有内容（不包含 `build` 目录自身）移动到当前 git 仓库的根目录，然后
```
git add .
git commit -m "Deploy website'
```
然后上传 `gh-pages` 分支，这样就可以在网页上的 github 仓库中的 `Settings | Pages` 中的 `Branch` 处选择 `gh-pages` 了。注： `Sourc` 处不要选择 `Github Actions` 而是选择 `Deploy from a branch` ，否则下一小节介绍的 `Github Actions`虽然运行成功但网站上的网页并未被更新。

最后，将当前分支从 `gh-pages` 切回 `master` 。

在“远端仓库中存在 `gh-pages` 分支”这一前提条件满足后，就可以成功运行 docusaurus 的集（在 master 分支中）生成和上传（到 gh-pages 分支）于一体的 `npm run deploy` 命令了，参见 [docusaurus: can deploy flyskywhy website with ./deploy-website.sh](https://github.com/flyskywhy/g/commit/175190ef3720875dde82765bf0ca825dd858ae16) 。

至此，手动更新网站的方法就是：更改自己的 md 文档（并上传）然后运行 `./deploy-website.sh` 。

如果使用下一小节介绍的 `Github Actions` 则可做到上传自己的 md 文档就自动更新网站的效果。

## 使用 GitHub Actions 自动生成网页并自动上传到 gh-pages 分支
创建 `.github/workflows/deploy.yml` 文件，文件内容参见[docusaurus: automatically deploy flyskywhy website with GitHub Actions](https://github.com/flyskywhy/g/commit/15c63350b417e2e938b44ed0d3587a48d3517a09) ，其中 `secrets.GITHUB_TOKEN` 不用在意在哪里给它赋值，只需要保证网页上的 github 仓库中的 `Settings | Actions | General` 中的 `Workflow permissions` 处选择 `Read and write permissions` 即可。

另， [https://rhysd.github.io/actionlint/](https://rhysd.github.io/actionlint/) 可以用来提前检查 `deploy.yml` 中的内容是否有语法错误。

按照 `deploy.yml` 中设定的规则，只要上传 master 分支，就会触发网页上的 github 仓库中的 `Actions | All workflows` 中的 `Deploy to GitHub Pages` ，进行网页生成然后（如果生成网页与上次不同就）自动提交上传到 gh-pages 分支，而后这个 gh-pages 上传动作又会触发 `Actions | All workflows` 中的 (Github 自带的) `pages-build-deployment` 。

至此，更新网站的方法就是：上传自己的 md 文档。
