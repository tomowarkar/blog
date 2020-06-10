---
title: "Mac のCPU周りを調べるコマンド"
date: 2020-06-10T23:05:15+09:00
draft: false
toc: true
images:
tags:
  - MacOS
---

## Mac バージョン

```
ProductName:    Mac OS X
ProductVersion: 10.15.4 (Catalina)
```

## CPU 使用率を確認する

### アクティビティモニターを開く

```bash
$ open /System/Applications/Utilities/Activity\ Monitor.app
```

### Dock のアイコンを操作

`アクティビティモニターの Dock アイコンを右(二本指)クリック -> モニタ -> CPU の履歴を表示`

これでコア数に応じた CPU 使用率のウィンドウが出てくる。

### アクティビティモニターのアイコン

上記の動作を行った方はすでにお気づきだろうが、同様の操作をしてアクティビティモニターのアイコンを CPU 使用率やネットワーク使用状況に変更する小 τ ができる。

`アクティビティモニターの Dock アイコンを右(二本指)クリック -> Dock アイコン -> CPU の履歴を表示, ネットワークの使用状況を表示 ... など`

今まで知らなかったのが悔しいくらいだ。

## CPU 温度を確認する

```bash
$ sudo powermetrics | grep -e "CPU die temperature"
CPU die temperature: 63.02 C

```

### powermetrics

powermetrics は他にも様々なシステム情報を調べることができる。

[powermetrics - Mozilla | MDN](https://developer.mozilla.org/en-US/docs/Mozilla/Performance/powermetrics)

#### より細かい情報

```bash
$ sudo powermetrics --show-all
```

#### CPU クロック?

```bash
$ sudo powermetrics | grep -e "CPU Average frequency"
CPU Average frequency as fraction of nominal: 123.82% (2476.43 Mhz)
CPU Average frequency as fraction of nominal: 121.37% (2427.45 Mhz)
CPU Average frequency as fraction of nominal: 124.31% (2486.29 Mhz)
CPU Average frequency as fraction of nominal: 121.89% (2437.85 Mhz)
```

#### GPU 使用率?

```bash
$ sudo powermetrics | grep -e "GPU Busy"
GPU 0 GPU Busy                      : 5.17%
```

#### CPU 使用率?

```bash
$ sudo powermetrics | grep -e "Avg Num of Cores Active"
Avg Num of Cores Active: 0.52
```

#### もちろんこんなこともできる

```bash
$ sudo powermetrics | grep -A8 "SMC sensors"
**** SMC sensors ****

CPU Thermal level: 52
IO Thermal level: 2
Fan: 1486 rpm
CPU die temperature: 63.44 C
CPU Plimit: 0.00
GPU Plimit (Int): 0.00
Number of prochots: 0
```
