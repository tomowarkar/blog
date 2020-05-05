---
title: "Google Colab で MeCab と CaboCha を使う。"
date: 2020-05-06T01:41:30+09:00
draft: false
toc: true
images:
tags:
  - colab
  - bash
  - python
---

[ソースコード Gist](https://gist.github.com/tomowarkar/021580fa52781ed0b0d913f46c8bb7e5)

## 概要

### MeCab

[MeCab 公式サイト](http://taku910.github.io/mecab/)

本体 src: `mecab-0.996.tar.gz`

DLlink:`https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE`

辞書 src: `mecab-ipadic-2.7.0-20070801.tar.gz`

DLlink: `https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM`

### CaboCha

[CaboCha 公式サイト](http://taku910.github.io/cabocha/)

本体 src: `cabocha-0.69.tar.bz2`

DLlink: `https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU`

Versions: https://drive.google.com/drive/folders/0B4y35FiV1wh7cGRCUUJHVTNJRnM

依存: CRF++ (0.55 以降), MeCab (0.993 以降), mecab-ipadic, mecab-jumandic, unidic のいずれか

### CRF++

[CRF++ 公式サイト](http://taku910.github.io/crfpp/)

本体 src: `CRF++-0.58.tar.gz`

DLlink: `https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ`

Versions: https://drive.google.com/drive/folders/0B4y35FiV1wh7fngteFhHQUN2Y1B5eUJBNHZUemJYQV9VWlBUb3JlX0xBdWVZTWtSbVBneU0

依存: C++ compiler (gcc 3.0 or higher)

## MeCab インストール

`%%bash`も含めること

```bash
%%bash
# mecabのインストール
apt-get install mecab swig libmecab-dev mecab-ipadic-utf8 >/dev/null
# mecab-pythonのインストール
pip -q install mecab-python3
```

## CRF++ インストール

```bash
%%bash
# crfppソースファイルダウンロード
fname=CRF++-0.58
curl -sL -o ${fname}.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ"
tar -zxf ${fname}.tar.gz
cd ${fname}
# crfppインストール
./configure --quiet
make >/dev/null
make install >/dev/null
ldconfig
cd ..
```

## CaboCha インストール

```bash
%%bash
# cabochaソースファイルダウンロード
fname=cabocha-0.69
url="https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU"
curl -sc /tmp/cookie ${url} >/dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -sLb /tmp/cookie ${url}"&confirm=${code}&id=${FILE_ID}" -o ${fname}.tar.bz2

# 少し時間がかかる
tar -jxf ${fname}.tar.bz2
# cabochaインストール
cd ${fname}
./configure  --quiet -with-charset=utf-8
make >/dev/null
make check >/dev/null
make install >/dev/null
ldconfig
cd ..

# cabocha-pythonのインストール
pip -q install cabocha-0.69/python/
```

## 結果確認

```bash
!mecab -v
!pip show mecab-python3
!cabocha -v
!pip show cabocha-python
```

```
mecab of 0.996

Name: mecab-python3
Version: 0.996.5

cabocha of 0.69

Name: cabocha-python
Version: 0.69
```

```python
import MeCab
tagger = MeCab.Tagger()
print(tagger.parse("隣の客はよく柿食う客だ。"))

import CaboCha
cp = CaboCha.Parser()
print(cp.parseToString("隣の客はよく柿食う客だ。"))
```

## 補足

### MeCab をソースからビルド

#### mecab 本体

```bash
%%bash
fname=mecab-0.996
curl -sL -o ${fname}.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE"
tar zxfv ${fname}.tar.gz
cd ${fname}
./configure
make
make check
sudo make install
ldconfig
cd ..
```

#### 辞書(mecab-ipadic)

```bash
%%bash
fname=mecab-ipadic-2.7.0-20070801
curl -L -o ${fname}.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM"
tar zxfv ${fname}.tar.gz
cd ${fname}
./configure --with-charset=utf8
make
sudo make install
ldconfig
cd ..
```

### make に失敗するエラー

現象: `No such file or directory`とでて`make`に失敗する

原因: インストールしたばかりのファイルのリンクができていない

解決法 1: `ldconfig`を使う

解決法 2: 自分でシンボリックリンクを作成

参考: [Raspberry Pi の Python3 で Mecab を使う](https://irukanobox.blogspot.com/2017/09/raspberry-pipython3mecab.html)

## おわりに

`apt`と`make`のサイレントコマンドがうまく機能せず,とりあえず`>/dev/null`にぶち込む形になってしまった。

とはいえこれで[言語処理 100 本ノック 2020](https://nlp100.github.io/ja/)の 5, 6 章が Google Colab 上で完結できるようになりました。

Colab でのインストールは永続化されないので、何度も使う場合は`drive`上で`tar`ファイルと依存の`deb`ファイルを保存しておくのが良さそうです。
