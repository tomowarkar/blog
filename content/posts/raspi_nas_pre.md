---
title: "Raspberry pi NAS化計画 - 事前準備"
date: 2020-06-12T14:29:12+09:00
draft: false
toc: true
images:
tags:
  - raspberrypi
---

## モチベーション

最近 Mac の usb コネクタの接続が不安定になり、充電ができなくなるという現象が発生した。
usb ポートは二つあるので今のところ致命傷には至っていないが、どちらのポートからも給電できなくなると Mac が大きな文鎮となってしまうのでその対策をしようというのが事始め。

## バックアップとれよ

現状 128GB の USB に `Timemachine` で Mac のバックアップがとってあり、よく使うファイルに関してはクラウドで管理しているのですが、`Timemachine`の扱いに不慣れな点と、Mac にしか互換性がない点, クラウドの通信量問題[^1]から新しくバックアップを用意しようと思いました。

## 外付け HDD を使って NAS を構築する

単純にバックアップをとるだけならそのまま外づけ HDD を接続すればいいのですが、せっかくなので NAS を作ってみようと思います。

幸い手元に[Raspberry Pi Zero WH](https://www.yodobashi.com/product/100000001003904466/)と[Raspberry Pi 4 ModelB 2GB](https://amzn.to/2UBGgpu)があるので、外付け HDD を購入するだけで挑戦することができます。

また NAS にすることでスマホや iPad からもコンテンツにアクセスしたいという意図もありました。

## HDD vs SSD

どっちがいいか考えてみたのですが、費用対容量の観点から HDD にし, [Transcend ポータブル HDD 1TB [TS1TSJ25M3S]](https://amzn.to/2zoDMn1)を購入しました。

また[Raspberry Pi Zero WH](https://www.yodobashi.com/product/100000001003904466/)を使って NAS を作ろうと考えていたため、速度のボトルネックは Raspi 側にくるのではないかと考えたのもあります。

バックアップがメインでアクセス性が良くなればいいという考え方です。

## Raspi zero vs 4

[Raspberry Pi Zero](https://www.yodobashi.com/product/100000001003904466/)と[Raspberry Pi 4](https://amzn.to/2UBGgpu)どちらが NAS に向いているかを考えれば、圧倒的に[Raspberry Pi 4](https://amzn.to/2UBGgpu)でしょう。

`USB 3.0`の通信速度と CPU スペックが存分にいかせます。

反面、NAS としての利用だけを考える場合少しオーバースペックになるのではないかと考えました。

なのでとりあえず[Raspberry Pi Zero](https://www.yodobashi.com/product/100000001003904466/)で作ってみて、問題がありそうであれば[Raspberry Pi 4](https://amzn.to/2UBGgpu)に乗り換えることにします。

## その他実装への参考

[Raspberry Pi Zero](https://www.yodobashi.com/product/100000001003904466/)と[ポータブル HDD](https://amzn.to/2zoDMn1)で NAS を作る利点は簡単に持ち運ぶことができる点です。それを踏まえ実装を考えていきます。

### HDD フォーマット

Mac と Windows のデフォルトのフォーマット形式は互換性がありません。どちらからもファイルの読み書きができるようにしたいです。

[RaspberryPi2 で Mac と Windows 両対応の NAS を構築する - Qiita](https://qiita.com/rkonno/items/54b2e4b8770c8b0b2bcd#comments)

### 複数 Wifi の設定

持ち運ぶ上でいちいち wifi を切り替えるのは手間です。

[ラズパイで複数のネットワーク設定をする - Qiita](https://qiita.com/hxbdy625/items/374394f3dff17bdaf843)

### そのた参考になりそうなもの

[openmediavault で exfat の外付けハードディスクを利用する](https://raspida.com/omv-exfat)

[ラズパイで自宅ファイルサーバを作る ～自作 NAS「openmediavault」編～ (1/4) - ITmedia NEWS](https://www.itmedia.co.jp/news/articles/2002/24/news008.html)

[Raspberry pi 4 で NAS（openmediavault）を構築する方法 - Qiita](https://qiita.com/zono_0/items/1eb877ad9c6e5ac12532)

[^1]: `ポータブルWi-Fiなので使える通信量に制限がある`
