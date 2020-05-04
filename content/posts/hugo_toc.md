---
title: "Hugo の目次機能を ON にしてみた"
date: 2020-05-05T02:36:57+09:00
draft: false
toc: true
images:
tags:
  - bash
  - regex
  - hugo
---

このブログで使用している `Hugo` のテーマは `hello-friend-ng` なのだが、目次機能がデフォルトでオフになっている。

そのためそもそもそんな機能あったのかというレベルだったのだが、デフォルトをオンに変更し、今まで書いた記事も一括で目次がつくように変更してみた。

## 記事のテンプレートをコピー

`themes`配下のテーマソースの中から記事のテンプレートとなっている部分をコピーしてくる。

たぶんどのテーマも共通で `archetypes` 配下にあるのではないだろうか。

`themes`配下のテーマソースを直接触らないように注意!!

```bash
cp {themes/hello-friend-ng/,}archetypes/posts.md
```

#### posts.md

そして値を変更する。

`hello-friend-ng`では`toc: true`の部分が目次表示の判定部分

```markdown
---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: false
toc: true
images:
tags:
  - untagged
---
```

## 目次のトピック文字変更

`hello-friend-ng`では目次のタイトルが`Table of Contents`になっているのでそれを変更する。

先ほどと同じ要領で該当ソースを見つけコピーして, 変更する.

```bash
mkdir i18n
cp {themes/hello-friend-ng/,}i18n/en.toml
```

#### en.toml

```toml
[tableOfContents]
other = "目次"
```

ここはもしかしたら`config.toml`をいじるだけで変更できるかもしれないが、わからないのでパス。

## 過去記事を一括変更

デフォルト値を変更しただけでは過去記事は目次非表示のままなので一括変更する。

みんな大好きシェルスクリプトだ。

```bash
grep -rl -e '^toc: false$' content/posts/ | xargs -n1 sed -i.bak 's/^toc: false$/toc: true/g'
```

`toc: false` -> `toc: true`に変更するだけなのですぐにできる。

git 管理しているのでミスがあれば `git checkout`

```bash
git checkout content/posts/
```

変更差分を確認して、問題なさそうであれば `.bak`ファイルも一括で削除する

パイプラインに渡す前に確認を忘れずに

```bash
find content/posts/*bak | xargs -n1 rm
```

### 参考

- [hello-friend-ng::Hugo Parameters](https://github.com/rhazdon/hugo-theme-hello-friend-ng/blob/20810b2afdcfc2b0636d0c3277f6f2633af70916/exampleSite/content/posts/goisforlovers.md#hugo-parameters)

- [Hugo::Table of Contents](https://gohugo.io/content-management/toc/)

```

```
