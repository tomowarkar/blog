---
title: "Youtubedl がいつもと違う挙動やエラーをはく時の対象法"
date: 2020-07-11T17:31:16+09:00
draft: false
toc: true
images:
tags:
  - untagged
---

Q. youtubedl で普段と違ったエラーが出ます

## A. まずはアップデートしましょう

```
sudo youtubedl -U
```

### U option

最新バージョンにアップデートしてくれるオプション

```
Options:
  General Options:
    -U, --update  Update this program to latest version. Make sure that you have sufficient permissions (run with sudo if needed)
```

## ダメです!それでも治りません

### Issues で同じ症状がないか探します

https://github.com/ytdl-org/youtube-dl/issues

そこで議論されている解決方法に頼る or パッチが当てられるのを待つ or 自分でスクリプトを書く

## 終わりに

対象サイトの仕様変更が原因となることが多いのでこまめにアップデートしましょうって感じ
