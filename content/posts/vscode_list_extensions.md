---
title: "VSCodeのインストール済み拡張機能とその用途"
date: 2020-04-10T15:16:15+09:00
draft: false
toc: true
images:
tags:
  - vscode
  - memo
---

個人的メモ

定期的に確認すると良さげですね

## VSCode プラグイン一覧の表示

```
code --list-extensions | xargs -L 1 echo code --install-extension
```

# 2020/04/10 現在

```
code --install-extension bbenoist.shell
code --install-extension christian-kohler.npm-intellisense
code --install-extension christian-kohler.path-intellisense
code --install-extension dariofuzinato.vue-peek
code --install-extension dbaeumer.vscode-eslint
code --install-extension donjayamanne.jupyter
code --install-extension eg2.vscode-npm-script
code --install-extension esbenp.prettier-vscode
code --install-extension formulahendry.auto-close-tag
code --install-extension formulahendry.auto-complete-tag
code --install-extension formulahendry.auto-rename-tag
code --install-extension formulahendry.code-runner
code --install-extension jcbuisson.vue
code --install-extension KnisterPeter.vscode-github
code --install-extension ms-azuretools.vscode-docker
code --install-extension MS-CEINTL.vscode-language-pack-ja
code --install-extension ms-mssql.mssql
code --install-extension ms-python.python
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.Go
code --install-extension ms-vscode.vscode-typescript-tslint-plugin
code --install-extension mubaidr.vuejs-extension-pack
code --install-extension octref.vetur
code --install-extension robertoachar.vscode-essentials-snippets
code --install-extension tht13.python
code --install-extension tombonnike.vscode-status-bar-format-toggle
code --install-extension tomoki1207.pdf
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension xabikos.JavaScriptSnippets
code --install-extension xaver.clang-format
code --install-extension yzhang.markdown-all-in-one
```

## 用途

### [bbenoist.shell](https://marketplace.visualstudio.com/items?itemName=bbenoist.shell)

- エディタから直接 shell コマンドを実行できる
- ほぼ使っていない

### [christian-kohler.path-intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)

- ファイル名を自動補完
- 賢くて良き

### [dbaeumer.vscode-eslint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)

- コードフォーマッター
- よくわからん

### [esbenp.prettier-vscode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

- コードフォーマッター
- [Prettier 入門 ～ ESLint との違いを理解して併用する～](https://qiita.com/soarflat/items/06377f3b96964964a65d)

### [eg2.vscode-npm-script](https://marketplace.visualstudio.com/items?itemName=eg2.vscode-npm-script)

- npm の hogehoge
- よくわからん

### [christian-kohler.npm-intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.npm-intellisense)

- npm モジュールを自動補完

### [dariofuzinato.vue-peek](https://marketplace.visualstudio.com/items?itemName=dariofuzinato.vue-peek)

- vue の hogehoge
- vue をあまり書いてないからよくわからん

### [jcbuisson.vue](https://marketplace.visualstudio.com/items?itemName=jcbuisson.vue)

- vue の Syntax Highlight
- まあいるよね

### [mubaidr.vuejs-extension-pack](https://marketplace.visualstudio.com/items?itemName=mubaidr.vuejs-extension-pack)

- vue 関連

### [octref.vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)

- 同上

### [formulahendry.auto-complete-tag](https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-complete-tag)

- 以下二つのまとめ役

### [formulahendry.auto-close-tag](https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-close-tag)

- html などの close tag 自動補完
- 必須

### [formulahendry.auto-rename-tag](https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-rename-tag)

- 便利
- 時々うざい

### [formulahendry.code-runner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

- VScode 上でのショートカット操作で外部の shell script を実行できる
- 入れたてホヤホヤ未使用様

### [KnisterPeter.vscode-github](https://marketplace.visualstudio.com/items?itemName=KnisterPeter.vscode-github)

- github 関連
- どこからどこまで何をしているのかわからない

### [ms-azuretools.vscode-docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

- docker for vscode
- あまり docker 触ってないなぁ

### [MS-CEINTL.vscode-language-pack-ja](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-ja)

- VSCode の日本語対応
- 必須

### [ms-mssql.mssql](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql)

- sql 関連

### [ms-python.python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

- python 関連
- 必須

### [tht13.python](https://marketplace.visualstudio.com/items?itemName=tht13.python)

- python 関連
- よくわからん

### [donjayamanne.jupyter](https://marketplace.visualstudio.com/items?itemName=donjayamanne.jupyter)

- jupyter notebook 　の hogehoge
- あると便利
- なくても困らん

### [xaver.clang-format](https://marketplace.visualstudio.com/items?itemName=xaver.clang-format)

- c 関連

### [ms-vscode.cpptools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)

- c/c++関連

### [ms-vscode.Go](https://marketplace.visualstudio.com/items?itemName=ms-vscode.Go)

- go 関連
- 必須

### [ms-vscode.vscode-typescript-tslint-plugin](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-typescript-tslint-plugin)

- 使ってないなぁ

### [robertoachar.vscode-essentials-snippets](https://marketplace.visualstudio.com/items?itemName=robertoachar.vscode-essentials-snippets)

- 見た感じ便利そう
- なお使ったことはない

### [tombonnike.vscode-status-bar-format-toggle](https://marketplace.visualstudio.com/items?itemName=tombonnike.vscode-status-bar-format-toggle)

- なんだ... これは...

### [tomoki1207.pdf](https://marketplace.visualstudio.com/items?itemName=tomoki1207.pdf)

- VSCode で PDF が見れる
- benri

### [VisualStudioExptTeam.vscodeintellicode](https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode)

- ものゴッツ便利

### [xabikos.JavaScriptSnippets](https://marketplace.visualstudio.com/items?itemName=xabikos.JavaScriptSnippets)

- JS
- こんなん知らんかった
- 今度使いたい

### [yzhang.markdown-all-in-one](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)

- markdown 関連
- 必須

## 参考

[Qiita::VSCode インストール済 プラグイン一覧の確認方法 (コマンド)](https://qiita.com/koshilife/items/3ed4b1c28de233f39ebb)
