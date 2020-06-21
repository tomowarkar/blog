---
title: "Raspberry Pi セットアップのTips"
date: 2020-05-22T21:55:40+09:00
draft: false
toc: true
images:
tags:
  - raspberrypi
---

raspberry pi の環境を作っては壊し、壊しては作りを繰り返しているので備忘録

## 実行環境

Mac Book Pro により ssh 接続で`raspberry pi`に接続、`CUI`操作をメインとする。

### Mac

```
ProductName:    Mac OS X
ProductVersion: 10.15.4
BuildVersion:   19E266
```

### Raspberry pi

基本的に`Zero WH`で動作確認をしているが、一部`4`でも動作確認済み

- Raspberry Pi Zero WH
- [Raspberry Pi 4 Model B (2GB)](https://amzn.to/2LQ2y1Z)

## Raspbian のダウンロード

- [公式](https://www.raspberrypi.org/downloads/raspbian/)
- [日本ミラーサイト](http://ftp.jaist.ac.jp/pub/raspberrypi/)

### raspbian-lite(var.2020/02/13) の例

```bash
curl -O http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
```

## SD カードのフォーマット

### ディスクの確認

```bash
diskutil list
```

自分の場合他の外部デバイス接続をしていない場合基本的に `/dev/disk2` に SD カードが割り当てられている。

### SD カードフォーマット

```bash
diskutil eraseDisk MS-DOS RPI /dev/disk2
```

フォーマット形式(`MS-DOS`)、ディスクの名前(`RPI`)、フォーマット対象ディスク(`/dev/disk2`)の順

#### memo

[NOOBS のインストールドキュメント](https://www.raspberrypi.org/documentation/installation/noobs.md)を見てると `~32GB` 容量の SD カードであれば `MS-DOS` でフォーマットしてやれば良さげ。

## イメージの書き込み

`dd`コマンドなるものでもできるらしいが、[Etcher](https://www.balena.io/etcher/)で行った。

[Copying an operating system image to an SD card using Mac OS](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md)

## 無線 LAN 設定

Mac でイメージを書き込んだあとに SD カードの名前が　`/Volumes/boot` と変わっている。

よってこのファイル内を変更することにより Mac 側で`raspberry pi`の設定を行う。

```bash
touch /Volumes/boot/ssh
```

## ネットワーク設定

```bash
read -p 'wifi_ssid: ' wifi_ssid
read -sp 'wifi_pswd: ' wifi_pswd

cat <<EOF >/Volumes/boot/wpa_supplicant.conf
country=JP
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="$wifi_ssid"
    psk="$wifi_pswd"
}
EOF
```

平文パスワードを嫌う場合[WPA key calculation](http://jorisvr.nl/wpapsk.html)を使ってパスワードを暗号化して記載することもできる。`wpa_passphrase`コマンドもあり。

また以下コマンドで Mac が接続している`Wi-Fi`を確認できる。

```bash
networksetup -getairportnetwork en0
```

### raspberry pi での wpa_supplicant.conf

`/etc/wpa_supplicant/wpa_supplicant.conf`に場所が変わっている

## ssh 接続

`ssh ユーザー名@IPアドレス`で接続することができる。

初期パスワードは`raspberry`

### raspberry pi の IP アドレス確認

```bash
arp -a
```

### raspberrypi への接続

より簡単には以下でも可能

```bash
ssh pi@raspberrypi.local
```

`ssh-keygen -R raspberrypi.local`

## これより以下 Mac 上で Raspberri Pi に ssh 接続していることが前提

## pi ユーザーのパスワード変更

raspberrypi の初期ユーザーとパスワードは公開されているため、一番最低限のセキュリティ対策として`pi`ユーザーのパスワード変更をすべきである。

```bash
$ passwd
```

## root ユーザーのパスワード変更

```bash
$ sudo passwd root
```

## 新規ユーザーの追加

```bash
$ sudo adduser ユーザー名
```

## 新規ユーザーに sudo 権限を追加

```bash
$ sudo gpasswd -a ユーザー名 sudo
```

## pi ユーザを sudo から外す

```bash
$ sudo gpasswd -d pi sudo
```

## 日本時間にする

`sudo timedatectl set-timezone Asia/Tokyo`

```bash
$ date
Sun Jun 14 08:01:52 BST 2020
$ sudo timedatectl set-timezone Asia/Tokyo
$ date
Sun Jun 14 16:03:39 JST 2020
```

## cron のログ出力

`sudo vim /etc/rsyslog.conf`

```
#cron.*                          /var/log/cron.log
↓
cron.*                          /var/log/cron.log
```

設定の反映

```bash
$ sudo /etc/init.d/rsyslog restart
```

[RaspberryPi3 で初めて crontab を使う前に - Qiita](https://qiita.com/Higemal/items/5a579b2701ef7c473062)

## [記載予定] エディタ設定

`nano` も良いが、せっかくだし`vim`を使えるようになりたい

[エディタ戦争](https://ja.wikipedia.org/wiki/%E3%82%A8%E3%83%87%E3%82%A3%E3%82%BF%E6%88%A6%E4%BA%89)

### vim-tiny アンインストール

```bash
$ sudo apt-get --purge remove vim-common vim-tiny
```

### vim インストール

```bash
$ sudo apt-get install vim
```

```
$ vim ~/.vimrc
```

## 日本語化

```
$ sudo apt-get update
$ sudo apt-get install fcitx-mozc
$ sudo reboot
```

```
$ locale
locale: Cannot set LC_CTYPE to default locale: No such file or directory
locale: LC_ALL??????????????????: ??????????????????????
LANG=ja_JP.UTF-8
LANGUAGE=
LC_CTYPE=UTF-8
LC_NUMERIC="ja_JP.UTF-8"
LC_TIME="ja_JP.UTF-8"
LC_COLLATE="ja_JP.UTF-8"
LC_MONETARY="ja_JP.UTF-8"
LC_MESSAGES="ja_JP.UTF-8"
LC_PAPER="ja_JP.UTF-8"
LC_NAME="ja_JP.UTF-8"
LC_ADDRESS="ja_JP.UTF-8"
LC_TELEPHONE="ja_JP.UTF-8"
LC_MEASUREMENT="ja_JP.UTF-8"
LC_IDENTIFICATION="ja_JP.UTF-8"
LC_ALL=

```

```bash
vi ~/.bashrc
```

```
export LANGUAGE=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export LC_TYPE=ja_JP.UTF-8

```

## pip

```bash
$ pip3 -V
-bash: pip3: コマンドが見つかりません
$ sudo apt-get install python3-pip
$ pip3 -V
pip 18.1 from /usr/lib/python3/dist-packages/pip (python 3.7)
```

`Original error was: libf77blas.so.3: cannot open shared object file: No such file or directory`
[ImportError: libf77blas.so.3: cannot open shared object file: No such file or directory · Issue #262 · Kitt-AI/snowboy](https://github.com/Kitt-AI/snowboy/issues/262)

```bash
$ sudo apt-get install libatlas-base-dev
```

## git

```bash
$ sudo apt-get install git
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"

```

## [記載予定] ip アドレスの固定化
