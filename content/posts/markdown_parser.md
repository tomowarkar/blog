---
title: "MarkdownからHTMLに変換する系のやつ"
date: 2020-05-12T20:27:32+09:00
draft: false
toc: true
images:
tags:
  - bash
  - markdown
---

マークダウンから html に変換コンバーターを bash で書いた。

[pandoc](https://pandoc.org/)とか使えば良いやんって話だけど、自家製で作りたいお年頃ですよね。

とは言っても、既存のものをガッツリ使用するのでサクッと作れてしまった。

## require

1. [マークダウンのスタイルを整えてくれるやつ](https://github.com/jasonm23/markdown-css-themes)
2. [マークダウンを HTML にしてくれるやつ](https://github.com/markedjs/marked)
3. [コードにハイライト入れてくれるやつ](https://highlightjs.org/)

を使います。

## マークダウンを HTML にしてくれるやつ のインストール

```bash
npm install -g marked
```

## ファイル構成

```bash
.
├── footer.html
├── header.html
├── hoge.md
├── parse.sh
└── style.css
```

### hoge.md

[今回のターゲット](#hogemd-1)

### footer.html

```html
<!-- highlight.js パーサー-->
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/highlight.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
</body>

</html>
```

### header.html

```html
<!DOCTYPE html>
<html lang="ja">

<head>
    <meta charset="UTF-8">
    <!-- markdown 全体 css -->
    <link href="https://rawgithub.com/jasonm23/markdown-css-themes/gh-pages/markdown7.css" rel="stylesheet">
    </link>
    <!-- markdown highlight.js css-->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/styles/vs.min.css">
    <!-- 調整用 css -->
    <link rel="stylesheet" type="text/css" href="style.css">
</head>

<body>
```

### style.css

```css
.hljs {
  background: none;
}

.code-title {
  display: inline-block;
  padding: 2px 4px;
  color: #333;
  transform: translateY(-0.5em);
  padding-bottom: 0;
  font-weight: bold;
  background-color: #999;
}
```

## メインコード

`header` と `footer`はテンプレートで使用し、マークダウンを HTML に変換した結果をサンドイッチする形をとります。

### parse.sh

```bash
#!/bin/bash -eu
# @(#) セルフパーサー

if [ ${1##*.} != "md" ] || [ ! -f $1 ]; then
    echo [error] $1 is not markdown or valid file
    exit 0
fi

tmpfile=$(mktemp)

cat $1 |
    marked |
    sed 's/<code class="language-\([^:]*:\)\([^"]*\)">/<div class="code-title">\2<\/div><code class="language-\1\2">/g' >${tmpfile}

cat header.html ${tmpfile} footer.html >${1%.*}.html

rm ${tmpfile}

```

1. とりあえず申し訳程度に入力形式を`md`に絞って、ファイルの存在を確かめてあげてから
2. 一時ファイルにマークダウンを HTML に変換した結果を格納
3. あとはテンプレートでサンドイッチ

としました。

間に使っている `sed` 処理は、マークダウンのコード部分にタイトルを挿入するためのやつです

{{<image src="https://i.imgur.com/iIWAQ7M.png" alt="blog top page" position="center">}}

正直これをしたいがためにマークダウン コンバーターを作りました。

ただ CSS をいじれば良いだけなのに無駄に労力を使った感じです。

## 動作検証

これが

### hoge.md

```
# H1
## H2

\`\`\`python:main.py
import numpy as np

arr = np.array([1, 2, 3])
\`\`\`

> 参照
```

```bash
sh parse.sh hoge.md
```

### hoge.html

こうなって

```html
<!DOCTYPE html>
<html lang="ja">

<head>
    <meta charset="UTF-8">
    <!-- markdown 全体 css -->
    <link href="https://rawgithub.com/jasonm23/markdown-css-themes/gh-pages/markdown7.css" rel="stylesheet">
    </link>
    <!-- markdown highlight.js css-->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/styles/vs.min.css">
    <!-- 調整用 css -->
    <link rel="stylesheet" type="text/css" href="style.css">
</head>

<body><h1 id="h1">H1</h1>
<h2 id="h2">H2</h2>
<pre><div class="code-title">main.py</div><code class="language-python:main.py">import numpy as np

arr = np.array([1, 2, 3])</code></pre>
<blockquote>
<p>参照</p>
</blockquote>

<!-- highlight.js パーサー-->
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/highlight.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
</body>

</html>
```

### blowser

こうなります
{{<image src="https://i.imgur.com/PCnvKeK.png" alt="blog top page" position="center">}}

やりたかったコードのタイトル部分もうまくできていて良きです。

## まとめ

Github でドキュメント作るときに変なプラグインを入れずに作れるので良さそう
