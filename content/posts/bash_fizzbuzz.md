---
title: "BashでFizzBuzzとか素数判定とか"
date: 2020-04-28T20:05:19+09:00
draft: false
toc: true
images:
tags:
  - bash
  - algorithm
---

## オーソドックスな FizzBuzz

数値部を弄るだけで様々なパターンに対応できる.

```bash
for i in {1..30}; do
    if (($i % 15 == 0)); then
        echo FizzBuzz
    elif (($i % 3 == 0)); then
        echo Fizz
    elif (($i % 5 == 0)); then
        echo Buzz
    else
        echo $i
    fi
done
```

## awk を用いた FizzBuzz

テキストを処理でよく用いられる`awk`を用いた処理.
こちらも処理内容としてはオーソドックス

```bash
seq 30 | awk '{
    if($1 % 15 == 0){
        print "FizzBuzz"
    }else if($1 % 3 == 0){
        print "Fizz"
    }else if($1 % 5 == 0){
        print "Buzz"
    }else{
        print $1}
    }'
```

## sed を用いた FizzBuzz

`n コマンド`を用いた少し特殊な FizzBuzz

短くワンライナーで書けてかっこいいが, パターンが変わる場合少し面倒

実行環境が Mac のため?か`3~3`(3 行目から 3 行毎)みたいな表記が使えない(方法あれば教えてください 🙇‍♀️)ので以下の実装。

```bash
seq 30 | sed 'n;n;n;n;s/[0-9]*/Buzz/' | sed 'n;n;s/[0-9]*/Fizz/'
```

### 0 から始まる場合

```bash
seq 0 30 | sed 'N;N;N;N;s/[0-9]*/Buzz/' | sed 'N;N;s/[0-9]*/Fizz/'

# きちんと30まで表示するには以下の様にする必要がある
seq 0 34 | sed 'N;N;N;N;s/[0-9]*/Buzz/' | sed 'N;N;s/[0-9]*/Fizz/' | head -n 31
```

### 面倒なところ

この表記はうまくいくが...

```bash
seq 30 | sed 'n;n;s/[0-9]*/Fizz/' | sed 'n;n;n;n;s/[0-9]*$/Buzz/'

ans1=`seq 30 | sed 'n;n;n;n;s/[0-9]*/Buzz/' | sed 'n;n;s/[0-9]*/Fizz/'`
ans2=`seq 30 | sed 'n;n;s/[0-9]*/Fizz/' | sed 'n;n;n;n;s/[0-9]*$/Buzz/'`

diff <(echo $ans1) <(echo $ans2) #>None
```

同じ様に`n;`を`N;`に変えるだけではうまくいかないこともある

```bash
seq 0 30 | sed 'N;N;s/[0-9]*/Fizz/' | sed 'N;N;N;N;s/[0-9]*$/Buzz/'

ans1=`seq 0 30 | sed 'N;N;N;N;s/[0-9]*/Buzz/' | sed 'N;N;s/[0-9]*/Fizz/'`
ans2=`seq 0 30 | sed 'N;N;s/[0-9]*/Fizz/' | sed 'N;N;N;N;s/[0-9]*$/Buzz/'`

diff <(echo $ans1) <(echo $ans2)
1c1
< FizzBuzz 1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz 16 17 Fizz 19 Buzz Fizz 22 23 Fizz Buzz 26 Fizz 28 29
---
> Fizz 1 2 Fizz Buzz 5 Fizz 7 8 FizzBuzz 10 11 Fizz 13 Buzz Fizz 16 17 Fizz Buzz 20 Fizz 22 23 FizzBuzz 25 26 Fizz 28 Buzz
```

別に`ans1`の方で問題ないが上手い書き方はないものか...

### 動作確認

```bash
ans1=`for i in {1..30}; do if (($i % 15 == 0)); then echo FizzBuzz; elif (($i % 3 == 0)); then echo Fizz; elif (($i % 5 == 0)); then echo Buzz; else echo $i; fi done`
ans2=`seq 30 | awk '{if($1 % 15 == 0){print "FizzBuzz"}else if($1 % 3 == 0){print "Fizz"}else if($1 % 5 == 0){print "Buzz"}else{print $1}}'`
ans3=`seq 30 | sed 'n;n;n;n;s/[0-9]*/Buzz/' | sed 'n;n;s/[0-9]*/Fizz/'`

# デバック用
diff <(echo $ans1) <(echo $ans2) #> None
diff <(echo $ans2) <(echo $ans3) #> None
diff <(echo $ans3) <(echo $ans1) #> None
```

#### memo

BSD ではなく GNU の`sed`では以下の様にも描ける様だ(未確認)

```bash
seq 30 | sed 's/.*5$/Buzz/;3~3s/[0-9]*/Fizz/'
```

参考: [シェルコマンドで FizzBuzz](https://qiita.com/gyu-don/items/f5440b16213200da9775)

### 素数判定

速度を考えないのであれば...

```bash
isprime() {
    [ $1 -lt 2 ] && return
    [ $1 -eq 2 ] && echo $1 && return
    for p in $(seq 2 $(expr $1 - 1)); do
        (($1 % $p == 0)) && return
    done
    echo $1
}

for i in $(seq 100); do
    isprime $i
done
```

`gfactor`(もしくは`factor`)を使う手もある(圧倒的に早い)

```bash
seq 100 | gfactor | awk 'NF == 2' | cut -d : -f1
```

#### なんか書いたけど使わなかったコード供養

```bash
max(){ [ $1 -gt $2 ] && echo $1 || echo $2; }
```
