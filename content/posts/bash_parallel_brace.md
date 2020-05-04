---
title: "Bashにおけるloopとかブレース展開とか並列行処理とか"
date: 2020-05-03T06:47:36+09:00
draft: false
toc: true
images:
tags:
  - bash
  - memo
---

## ブレース展開

```bash
# こんなんとか
echo {1..10} #> 1 2 3 4 5 6 7 8 9 10

# こんなんとか
echo {{a..z},{A..Z}} #> a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
```

#### 深いディレクトリ操作とかで便利

ファイル名を typo した時の変更とかに

```bash
mv content/posts/bash_parallel_{braves,brace}.md
```

以下と同意

```bash
mv content/posts/bash_parallel_braves.md content/posts/bash_parallel_brace.md
```

もちろん`cp` や `touch`などでも使える

```bash
$ mkdir -p test/{hoga,hige}/{1..3}
$ tree test/
test/
├── hige
│   ├── 1
│   ├── 2
│   └── 3
└── hoga
    ├── 1
    ├── 2
    └── 3
```

### Mac のブレース展開で詰まったところ

年月を`%Y%m`で表示したい

```bash
# 期待
echo {2020..2020}{01..12} #> 202001 202002 202003 202004 202005 202006 202007 202008 202009 202010 202011 202012

# 現実 #> 20201 20202 20203 20204 20205 20206 20207 20208 20209 202010 202011 202012
```

0 パディングされなくて悲しい

### 解決策

```bash
# ゴリ押し法
echo {2020..2020}{{01,02,03,04,05,06,07,08,09},{10..12}}

# xargs and printf法
str=$(echo {01..12} | xargs -n1 -I{} printf "%02d," {} | sed -e 's/,$//g')
eval echo {2020..2020}{$str}

# seq and sed法
str=$(seq -w -s ',' 1 12 | sed -e 's/,$//g')
eval echo {2020..2020}{$str}

# sed法
str=$(echo {101..112} | sed -e 's/1\([0-9]\{2\}\)/\1/g' -e 's/\ /,/g')
eval echo {2020..2020}{$str}
```

## for loop の速度

ところで年月を`%Y%m`で表示したいと考えたときに一番簡単に実装できる方法が`for loop`を用いた実装ではないだろうか

巷では`for loop`は遅いと言われているが実際はどうなのか確かめてみる。

### 0 パディングなし

```bash
f1() {
    for yy in $(seq 2020 2020); do
        for m in $(seq 1 12); do
            echo $yy$m >/dev/null
        done
    done
}
time -p (for i in {1..1000}; do f1; done)
# >real 5.02 user 1.53 sys 2.75

f2() {
    for yy in {2020..2020}; do
        for m in {1..12}; do
            echo $yy$m >/dev/null
        done
    done
}
time -p (for i in {1..1000}; do f2; done)
# >real 0.44 user 0.21 sys 0.23

## 比較
time -p (for i in {1..1000}; do echo {2020..2020}{{01,02,03,04,05,06,07,08,09},{10..12}}>/dev/null; done)
#> real 0.08 user 0.06 sys 0.02
```

#### question

こちらのが比較としてより正しい気がするけどどうなのだろうか(ちなみにものすごく遅い)

```bash
time -p (for i in {1..1000}; do echo {2020..2020}{{01,02,03,04,05,06,07,08,09},{10..12}}| xargs -n1 -I{} echo {} >/dev/null; done)
# >real 16.82 user 5.57 sys 10.83

# 並列処理しても遅い
time -p (for i in {1..1000}; do echo {2020..2020}{{01,02,03,04,05,06,07,0
8,09},{10..12}}| xargs -n1 -P4 -I{} echo {} >/dev/null; done)
# >real 8.99 user 6.64 sys 14.65
```

## 並列処理

ついでなので`xargs`での並列処理についてメモを残しておく

#### 基本

```bash
$ seq 10 | xargs echo
1 2 3 4 5 6 7 8 9 10

$ seq 10 | xargs -t echo
echo 1 2 3 4 5 6 7 8 9 10
1 2 3 4 5 6 7 8 9 10

$ seq 10 | xargs -t -n1 echo
echo 1
1
echo 2
2
echo 3
3
echo 4
4
echo 5
5
echo 6
6
echo 7
7
echo 8
8
echo 9
9
echo 10
10
```

- `-t` 実行コマンドを表示
- `-n` 引数の数を指定

#### n コマンドと L コマンドの違い

- `-n` 区切り文字 `' '`(スペース)で分割?
- `-L` 区切り文字 `\n`で分割?

```bash
# 以下二つは同様の結果を示す
$ seq 10 | xargs -t -n3 echo
$ seq 10 | xargs -t -L3 echo

# 違い
$ seq  -s ' ' 10 | xargs -t -n3 echo
echo 1 2 3
1 2 3
echo 4 5 6
4 5 6
echo 7 8 9
7 8 9
echo 10
10
$ seq  -s ' ' 10 | xargs -t -L3 echo
echo 1 2 3 4 5 6 7 8 9 10
1 2 3 4 5 6 7 8 9 10
```

#### 引数の操作

```bash
$ seq 10 | xargs -t -n2 bash -c '[ $0 -gt $1 ] && echo $0 || echo $1'
bash -c [ $0 -gt $1 ] && echo $0 || echo $1 1 2
2
bash -c [ $0 -gt $1 ] && echo $0 || echo $1 3 4
4
bash -c [ $0 -gt $1 ] && echo $0 || echo $1 5 6
6
bash -c [ $0 -gt $1 ] && echo $0 || echo $1 7 8
8
bash -c [ $0 -gt $1 ] && echo $0 || echo $1 9 10
10
```

#### 並列処理

途中経過より正しく並列処理されていることを確認

```bash
time -p seq 10 | xargs -t -I{} bash -c 'echo {} >/dev/null && sleep 1'
# >real 10.13 user 0.02 sys 0.05
time -p seq 10 | xargs -t -I{} -P2 bash -c 'echo {} >/dev/null && sleep 1'
# >real 5.07 user 0.02 sys 0.06
time -p seq 10 | xargs -t -I{} -P10 bash -c 'echo {} >/dev/null && sleep 1'
# >real 1.08 user 0.02 sys 0.07
```

引数の数をしてして実行

```bash
time seq 10 | xargs -t -I{} -L2 bash -c 'echo {} >/dev/null && sleep 1'
time seq 10 | xargs -t -I{} -L2 -P2 bash -c 'echo {} >/dev/null && sleep 1'
```

### 使わなかったコード供養

```bash
red(){ echo $'\e[31m'$1$'\e[0m' ;}
red hoge
```

参考 [ANSI エスケープシーケンス チートシート](https://qiita.com/PruneMazui/items/8a023347772620025ad6)

参考 https://sites.google.com/a/tatsuo.jp/programming/Home/bash/hentai-bunpou-saisoku-masuta#TOC--6

```bash
eval echo $(echo {$(seq -w 1 12)} | tr ' ' ',') #> 01 02 03 04 05 06 07 08 09 10 11 12
```

```bash
f2() {
    for yy in {2020..2020}; do
        for m in {1..12}; do
            [ $m -lt 10 ] && printf "%s0%s\n" $yy $m  || echo $yy$m
        done
    done
}
```

日付めくりとかだと使えるかもね

```bash
since="2020/01/01"
till="2020/12/01"
dy=$(gdate -d $since +%Y%m)
ft=$(gdate -d $till +%Y%m)
monthes=0

while [ $dy -le $ft ]; do
    echo $dy
    monthes=$((++monthes))
    dy=$(gdate -d "$since $monthes month" +%Y%m)
done

```
