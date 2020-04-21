---
title: "最近よく書くシェルスクリプトの備忘録"
date: 2020-04-21T19:16:51+09:00
draft: false
toc: false
images:
tags:
  - bash
  - memo
---

## 実行環境
```bash
$ sw_vers
ProductName:    Mac OS X
ProductVersion: 10.15.4
BuildVersion:   19E266

$ sh --version
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin19)
Copyright (C) 2007 Free Software Foundation, Inc.
```

## Linux コマンド
### ファイルの中身を表示する
```bash
# 一番有名? 間違えてバイナリファイルなどを指定すると悲惨
cat /path/to/file
# ファイルの一部を表示, スクロールして中身を見ることができる。
less /path/to/file
# less の出力結果を残す版
more /path/to/file
```
### ヒアドキュメント
```bash
cat <<EOL >/path/to/file
hoge
huga
EOL
```

参考 [bashのヒアドキュメントを活用する](https://qiita.com/take4s5i/items/e207cee4fb04385a9952)
### dateコマンド
```bash
$ date -R
Tue, 21 Apr 2020 18:50:48 +0900

$ date +%y%m%d
200421
# 昨日の日付
$ date -v -1d +%y%m%d
200420
```
### sayコマンド
```bash
$ say -v ? | grep "ja_JP"
Kyoko               ja_JP    # こんにちは、私の名前はKyokoです。日本語の音声をお届けします。
Otoya               ja_JP    # こんにちは、私の名前はOtoyaです。日本語の音声をお届けします。

$ say -v Bad\ News Kgo mo ichi ni chi gamba lu zowi Kgo mo ichi ni chi gamba lu zowi
```
参考 [非実用 say コマンド](https://gist.github.com/susisu/c9b106745f94c85e482c)

### afplay コマンド
```bash
# バックグラウンド再生
$ afplay -q 1 /path/to/audio/file &
# 中断
$ killall afplay
```
## シェルスクリプト
### シェルスクリプトの説明文
##### hoge.sh
```bash
#!/bin/bash
# @(#) This script is hoge.
```
```bash
$ what hoge.sh 
hoge.sh
         This script is hoge.
```

### ファイルの初期化
```bash
# touch だと作成済みのファイルは初期化されない
touch /path/to/file

# これでもいいけど
echo -n "" > /path/to/file

# こっちのがスマート
:> /path/to/file
```
### 演算子
コマンドが成功した時と失敗した時とでの場合わけ
```bash
$ true && echo 1 || echo 2
>> 1
$ false && echo 1 || echo 2
>> 2
```

### 拡張子を取り除きたい
```bash
$ f="hoge.md"
$ echo ${f%.*}
>> hoge
```

参考 [bashの変数展開によるファイル名や拡張子の取得](https://qiita.com/mriho/items/b30b3a33e8d2e25e94a8)

### 引数をループ
```bash
for arg; do
    echo $arg
done
```
### 無限ループ
```bash
while true; do
    :
done
```
### for ループ
```bash
for i in aa bb cc; do
    echo $i
done

for i in $(seq 10); do
    echo $i
done

for ((i = 1; i < 11; i++)); do
    echo $i
done
```
### ls ループ
```bash
for f in *; do
    echo $f
done
```
### ファイル内ループ
```bash
while read line; do
　　echo $line
done < /path/to/file
```
## 引数解析
```bash
COMMAND=`basename $0`
while getopts ab: OPT
do
  case $OPT in
    a ) OPTION_a="TRUE" ;;
    b ) OPTION_b="TRUE" ; VALUE_b="$OPTARG" ;;
    * ) echo "Usage: " ; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))

if [ "$OPTION_b" = "TRUE" ]; then
    :
fi
```
### 途中終了時実行コマンド
Ctl+c でスクリプト実行が途中終了した時のコマンドを指定できる
```bash
trap "echo \"\n途中終了!!\"" 0
```

