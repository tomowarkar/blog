---
title: "[macOS] コマンドラインで音楽を流したい"
date: 2020-04-12T23:33:30+09:00
draft: false
toc: false
images:
tags:
  - bash
  - memo
---

## 環境

```
$ bash --version
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin19)
Copyright (C) 2007 Free Software Foundation, Inc.
```

```
$ afplay -h

    Audio File Play
    Version: 2.0
    Copyright 2003-2013, Apple Inc. All Rights Reserved.
    Specify -h (-help) for command options

Usage:
afplay [option...] audio_file

Options: (may appear before or after arguments)
  {-v | --volume} VOLUME
    set the volume for playback of the file
  {-h | --help}
    print help
  { --leaks}
    run leaks analysis
  {-t | --time} TIME
    play for TIME seconds
  {-r | --rate} RATE
    play at playback rate
  {-q | --rQuality} QUALITY
    set the quality used for rate-scaled playback (default is 0 - low quality, 1 - high quality)
  {-d | --debug}
    debug print output
```

### 再生

quality はデフォルト値が low である 0 なので 1 に変更

音量は適宜

```
$ afplay -q 1 -v .1 path/to/audio_file
```

### バックグラウンド実行, プロセスの確認, プロセス kill

```
$ afplay path/to/audio_file &
[1] PID
$ jobs
[1]+  Running afplay path/to/audio_file &
$ # kill %ジョブ番号
$ kill %1
$ # もしくは
$ kill PID
```

見つからない場合や、他のターミナルから kill

```
ps aux | grep afplay | grep -v grep | awk '{ print "kill -9", $2 }' | sh
```

## 参考

- [徹底的にソフトウェアで豊かな音を奏でてみよう](https://zariganitosh.hatenablog.jp/entry/20100908/itunes)
- [Linux コマンド(Bash)でバックグラウンド実行する方法のまとめメモ](https://qiita.com/inosy22/items/341cfc589494b8211844)
- [シェルスクリプトで単純に並列実行・直列実行を行う](https://qiita.com/nyango/items/7b6b719f248b2ee8d379)
- [プロセス名で grep した結果を kill するシェルスクリプトを作る](https://qiita.com/masarufuruya/items/409679c1006980ef1b60)
