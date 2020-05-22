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

平文パスワードを嫌う場合[WPA key calculation](http://jorisvr.nl/wpapsk.html)を使ってパスワードを暗号化して記載することもできる。

また以下コマンドで Mac が接続している`Wi-Fi`を確認できる。

```bash
networksetup -getairportnetwork en0
```

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

## [記載予定] cron のログ出力

```
# sed -i -e 's/^#cron.* /^cron.* /' /etc/rsyslog.conf
```

## [記載予定] ip アドレスの固定化

## [記載予定] エディタ設定

`nano` も良いが、せっかくだし`vim`を使えるようになりたい

[エディタ戦争](https://ja.wikipedia.org/wiki/%E3%82%A8%E3%83%87%E3%82%A3%E3%82%BF%E6%88%A6%E4%BA%89)
