---
title: "RaspbianをDocker イメージに変換した(for Mac)"
date: 2020-05-15T11:14:25+09:00
draft: false
toc: true
images:
tags:
  - docker
  - raspbian
---

## モチベーション

Raspberry pi 上で Docker を使ってサーバーを立てる記事を漁っていたら 「[Raspbian を Docker イメージに変換する](https://qiita.com/yuyakato/items/5dd06fb179922206044d)」 という記事を見つけ、Docker の勉強にもなりそうだしやってみようかっていうところが始点。

## 実行環境

```bash
$ sw_vers
ProductName:    Mac OS X
ProductVersion: 10.15.4
BuildVersion:   19E266
```

## Raspbian のダウンロード

[本家](https://www.raspberrypi.org/downloads/raspbian/)ではかなり時間がかかるので, [日本のミラーサイト](http://ftp.jaist.ac.jp/pub/raspberrypi/)でダウンロードする

### ちなみに SHA-256 って何に使うんや?

本家のダウンロードサイトにはダウンロードファイルと一緒に SHA-256 の文字列が記載されている。最初これは何に使うんだろうかって思っていたのだが、どうやら破損や改変がないか調べるためらしい。

```bash
$ curl -O http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip

$ sha256sum 2020-02-13-raspbian-buster-lite.zip
12ae6e17bf95b6ba83beca61e7394e7411b45eba7e6a520f434b0748ea7370e8  2020-02-13-raspbian-buster-lite.zip
```

`$ diff <(echo before) <(echo after)` とかで本家記載のと差分が出なければ破損や改変がないと言えるっぽい

## 今回はルートファイルシステムを使う

参考: <https://docs.docker.com/engine/reference/commandline/import/>

### ダウンロードとイメージ作成を別々に行う

```bash
$ curl -O http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian_lite/archive/2020-02-14-13:49/root.tar.xz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  273M  100  273M    0     0  3543k      0  0:01:18  0:01:18 --:--:-- 2465k

$ docker image import ./root.tar.xz raspbian-buster-lite:2020-02-13
sha256:93b0d6a68bdedb4659c8311c55a2edf2717c63ff1c9e0e3e57f831fddc806cdc

$ docker image ls raspbian-buster-lite:2020-02-13
REPOSITORY             TAG                 IMAGE ID            CREATED              SIZE
raspbian-buster-lite   2020-02-13          93b0d6a68bde        About a minute ago   1.03GB

```

### ダウンロードとイメージ作成を一緒に

上記でイメージを作った後に公式ドキュメントを見て, こちらでもできるのではないかと思いやって見たらできたのでこちらも載せます。

同じイメージを作るのもなので、通常盤の`raspbian`のイメージを作りました。

    $ docker image import http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian/archive/2020-02-14-13:48/root.tar.xz raspbian-buster:2020-02-13
    Downloading from http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian/archive/2020-02-14-13:48/root.tar.xz
    Importing [==================================================>]  833.1MB/833.1MB
    sha256:38ac3326cfc4a5a8dca2d6f09505cfd26b884ff448c26aaff31fb60aee3c131d

    $ docker image ls raspbian-buster:2020-02-13
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    raspbian-buster     2020-02-13          38ac3326cfc4        About a minute ago      2.6GB

どちらもイメージにするとサイズが 3 倍近くになっているのがわかりますね。

## アーキテクチャとか

CPU に関しての知識は`Intel`と`AMD`は聞いたことがあるぞ!

うちの MacBook Pro にはデュアルコアの Intel Core i5 がのってるぞ!

くらいの知識程度しかないので実際にコマンドを叩いて確認していく。

### Mac のアーキテクチャ

`arch` コマンドと `uname -m`コマンドは同じとの説明を見たが、実際コマンドを叩いてみると値が違ったなぜ??

```bash
$ arch && uname -m
i386
x86_64
```

システム詳細の該当部分は多分これ?

```bash
$ sysctl hw.machine
hw.machine: x86_64
```

`arc`コマンドで 32 ビットバージョンで認識されてるのはなぜなのか。いつかソースを見にいこう。きっと。多分。

### raspbian のアーキテクチャ

armv7l という 32bit プロセッサを使っているらしい

[RaspbianFAQ](https://www.raspbian.org/RaspbianFAQ)

### 作成した raspbian docker イメージのアーキテクチャ

```bash
$ docker inspect --format='{{.Architecture}}' raspbian-buster-lite:2020-02-13
amd64
```

### 完全に理解した(うん、全くわからん)

つまりインテルの 64bitCPU 搭載の MacBookPro で, ARM の 32bit プロセッサ用の OS(Rapbian)を AMD の 64bit アーキテクチャとして Docker Image 化したってこと???

## とりあえず動かせば良い

[Docker docs](http://docs.docker.jp/engine/reference/run.html#)

    $ docker container run --interactive --tty --rm raspbian-buster-lite:2020-02-13 /bin/bash

    # uname -a
    Linux 1b55f48bb6e4 4.19.76-linuxkit #1 SMP Thu Oct 17 19:31:58 UTC 2019 armv7l GNU/Linux

どうやらアーキテクチャは armv7l になっている。

### docker で気になったところ

docker 初心者なので`docker run`と`docker container run`って何が違うんやと気になったのでメモ

結から言えば, 新コマンド と旧コマンドの違いだけでやっていることは同じらしい。ざっと見た感じ`image`を扱っているのか,　`container`を扱っているのかをわかりやすく明示的になるようコマンドが再編されたっぽい。

[docker container / image コマンド新旧比較](https://qiita.com/zembutsu/items/6e1ad18f0d548ce6c266)

## おわりに

結構軽い気持ちで Raspbian を Docker イメージに変換してみたワケだがものすごく簡単にでき、かつアーキテクチャや Docker を学ぶ良い機会になった。

以下に Raspbian Lite のインストールパッケージリストと 通常盤 Raspbian との差分を載せておく

## インストールされているパッケージリスト(Raspbian Lite var 2020-02-13)

    # dpkg --get-selections | grep -v deinstall | wc -l
    472

    # dpkg -l
    Desired=Unknown/Install/Remove/Purge/Hold
    | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
    |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
    ||/ Name                           Version                             Architecture Description
    +++-==============================-===================================-============-===============================================================================
    ii  adduser                        3.118                               all          add and remove users and groups
    ii  alsa-utils                     1.1.8-2                             armhf        Utilities for configuring and using ALSA
    ii  apt                            1.8.2                               armhf        commandline package manager
    ii  apt-listchanges                3.19                                all          package change history notification tool
    ii  apt-utils                      1.8.2                               armhf        package management related utility programs
    ii  avahi-daemon                   0.7-4+b1                            armhf        Avahi mDNS/DNS-SD daemon
    ii  base-files                     10.3+rpi1+deb10u2                   armhf        Debian base system miscellaneous files
    ii  base-passwd                    3.5.46                              armhf        Debian base system master password and group files
    ii  bash                           5.0-4                               armhf        GNU Bourne Again SHell
    ii  bash-completion                1:2.8-6                             all          programmable completion for the bash shell
    ii  bind9-host                     1:9.11.5.P4+dfsg-5.1                armhf        DNS lookup utility (deprecated)
    ii  binutils                       2.31.1-16+rpi1                      armhf        GNU assembler, linker and binary utilities
    ii  binutils-arm-linux-gnueabihf   2.31.1-16+rpi1                      armhf        GNU binary utilities, for arm-linux-gnueabihf target
    ii  binutils-common:armhf          2.31.1-16+rpi1                      armhf        Common files for the GNU assembler, linker and binary utilities
    ii  bluez                          5.50-1+rpt1                         armhf        Bluetooth tools and daemons
    ii  bluez-firmware                 1.2-4+rpt2                          all          Firmware for Bluetooth devices
    ii  bsdmainutils                   11.1.2                              armhf        collection of more utilities from FreeBSD
    ii  bsdutils                       1:2.33.1-0.1                        armhf        basic utilities from 4.4BSD-Lite
    ii  build-essential                12.6                                armhf        Informational list of build-essential packages
    ii  busybox                        1:1.30.1-4                          armhf        Tiny utilities for small and embedded systems
    ii  bzip2                          1.0.6-9.2~deb10u1                   armhf        high-quality block-sorting file compressor - utilities
    ii  ca-certificates                20190110                            all          Common CA certificates
    ii  cifs-utils                     2:6.8-2                             armhf        Common Internet File System utilities
    ii  console-setup                  1.193~deb10u1                       all          console font and keymap setup program
    ii  console-setup-linux            1.193~deb10u1                       all          Linux specific part of console-setup
    ii  coreutils                      8.30-3                              armhf        GNU core utilities
    ii  cpio                           2.12+dfsg-9                         armhf        GNU cpio -- a program to manage archives of files
    ii  cpp                            4:8.3.0-1+rpi2                      armhf        GNU C preprocessor (cpp)
    ii  cpp-8                          8.3.0-6+rpi1                        armhf        GNU C preprocessor
    ii  crda                           3.18-1                              armhf        wireless Central Regulatory Domain Agent
    ii  cron                           3.0pl1-134+deb10u1                  armhf        process scheduling daemon
    ii  curl                           7.64.0-4                            armhf        command line tool for transferring data with URL syntax
    ii  dash                           0.5.10.2-5                          armhf        POSIX-compliant shell
    ii  dbus                           1.12.16-1                           armhf        simple interprocess messaging system (daemon and utilities)
    ii  dc                             1.07.1-2                            armhf        GNU dc arbitrary precision reverse-polish calculator
    ii  debconf                        1.5.71                              all          Debian configuration management system
    ii  debconf-i18n                   1.5.71                              all          full internationalization support for debconf
    ii  debconf-utils                  1.5.71                              all          debconf utilities
    ii  debianutils                    4.8.6.1                             armhf        Miscellaneous utilities specific to Debian
    ii  device-tree-compiler           1.4.7-3+rpt1                        armhf        Device Tree Compiler for Flat Device Trees
    ii  dhcpcd5                        1:8.1.2-1+rpt1                      armhf        DHCPv4, IPv6RA and DHCPv6 client with IPv4LL support
    ii  diffutils                      1:3.7-3                             armhf        File comparison utilities
    ii  dirmngr                        2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - network certificate management service
    ii  distro-info-data               0.41+deb10u1                        all          information about the distributions' releases (data files)
    ii  dmidecode                      3.2-1                               armhf        SMBIOS/DMI table decoder
    ii  dmsetup                        2:1.02.155-3                        armhf        Linux Kernel Device Mapper userspace library
    ii  dosfstools                     4.1-2                               armhf        utilities for making and checking MS-DOS FAT filesystems
    ii  dphys-swapfile                 20100506-5                          all          Autogenerate and use a swap file
    ii  dpkg                           1.19.7                              armhf        Debian package management system
    ii  dpkg-dev                       1.19.7                              all          Debian package development tools
    ii  e2fsprogs                      1.44.5-1+deb10u2                    armhf        ext2/ext3/ext4 file system utilities
    ii  ed                             1.15-1                              armhf        classic UNIX line editor
    ii  ethtool                        1:4.19-1                            armhf        display or change Ethernet device settings
    ii  fake-hwclock                   0.11+rpt1                           all          Save/restore system clock on machines without working RTC hardware
    ii  fakeroot                       1.23-1                              armhf        tool for simulating superuser privileges
    ii  fbset                          2.1-30                              armhf        framebuffer device maintenance program
    ii  fdisk                          2.33.1-0.1                          armhf        collection of partitioning utilities
    ii  file                           1:5.35-4+deb10u1                    armhf        Recognize the type of data in a file using "magic" numbers
    ii  findutils                      4.6.0+git+20190209-2                armhf        utilities for finding files--find, xargs
    ii  firmware-atheros               1:20190114-1+rpt4                   all          Binary firmware for Atheros wireless cards
    ii  firmware-brcm80211             1:20190114-1+rpt4                   all          Binary firmware for Broadcom/Cypress 802.11 wireless cards
    ii  firmware-libertas              1:20190114-1+rpt4                   all          Binary firmware for Marvell wireless cards
    ii  firmware-misc-nonfree          1:20190114-1+rpt4                   all          Binary firmware for various drivers in the Linux kernel
    ii  firmware-realtek               1:20190114-1+rpt4                   all          Binary firmware for Realtek wired/wifi/BT adapters
    ii  flashrom                       1.0-1                               armhf        Identify, read, write, erase, and verify BIOS/ROM/flash chips
    ii  fuse                           2.9.9-1                             armhf        Filesystem in Userspace
    ii  g++                            4:8.3.0-1+rpi2                      armhf        GNU C++ compiler
    ii  g++-8                          8.3.0-6+rpi1                        armhf        GNU C++ compiler
    ii  gcc                            4:8.3.0-1+rpi2                      armhf        GNU C compiler
    ii  gcc-4.9-base:armhf             4.9.4-2+rpi1+b19                    armhf        GCC, the GNU Compiler Collection (base package)
    ii  gcc-5-base:armhf               5.5.0-8                             armhf        GCC, the GNU Compiler Collection (base package)
    ii  gcc-6-base:armhf               6.5.0-1+rpi1+b1                     armhf        GCC, the GNU Compiler Collection (base package)
    ii  gcc-7-base:armhf               7.3.0-19                            armhf        GCC, the GNU Compiler Collection (base package)
    ii  gcc-8                          8.3.0-6+rpi1                        armhf        GNU C compiler
    ii  gcc-8-base:armhf               8.3.0-6+rpi1                        armhf        GCC, the GNU Compiler Collection (base package)
    ii  gdb                            8.2.1-2                             armhf        GNU Debugger
    ii  gdbm-l10n                      1.18.1-4                            all          GNU dbm database routines (translation files)
    ii  geoip-database                 20181108-1                          all          IP lookup command line tools that use the GeoIP library (country database)
    ii  gettext-base                   0.19.8.1-9                          armhf        GNU Internationalization utilities for the base system
    ii  gnupg                          2.2.12-1+rpi1+deb10u1               all          GNU privacy guard - a free PGP replacement
    ii  gnupg-l10n                     2.2.12-1+rpi1+deb10u1               all          GNU privacy guard - localization files
    ii  gnupg-utils                    2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - utility programs
    ii  gpg                            2.2.12-1+rpi1+deb10u1               armhf        GNU Privacy Guard -- minimalist public key operations
    ii  gpg-agent                      2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - cryptographic agent
    ii  gpg-wks-client                 2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - Web Key Service client
    ii  gpg-wks-server                 2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - Web Key Service server
    ii  gpgconf                        2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - core configuration utilities
    ii  gpgsm                          2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - S/MIME version
    ii  gpgv                           2.2.12-1+rpi1+deb10u1               armhf        GNU privacy guard - signature verification tool
    ii  grep                           3.3-1                               armhf        GNU grep, egrep and fgrep
    ii  groff-base                     1.22.4-3                            armhf        GNU troff text-formatting system (base system components)
    ii  gzip                           1.9-3                               armhf        GNU compression utilities
    ii  hardlink                       0.3.2                               armhf        Hardlinks multiple copies of the same file
    ii  hostname                       3.21                                armhf        utility to set/show the host name or domain name
    ii  htop                           2.2.0-1                             armhf        interactive processes viewer
    ii  ifupdown                       0.8.35                              armhf        high level tools to configure network interfaces
    ii  info                           6.5.0.dfsg.1-4+b1                   armhf        Standalone GNU Info documentation browser
    ii  init                           1.56+nmu1                           armhf        metapackage ensuring an init system is installed
    ii  init-system-helpers            1.56+nmu1                           all          helper tools for all init systems
    ii  initramfs-tools                0.133+deb10u1                       all          generic modular initramfs generator (automation)
    ii  initramfs-tools-core           0.133+deb10u1                       all          generic modular initramfs generator (core tools)
    ii  install-info                   6.5.0.dfsg.1-4+b1                   armhf        Manage installed documentation in info format
    ii  iproute2                       4.20.0-2                            armhf        networking and traffic control tools
    ii  iptables                       1.8.2-4                             armhf        administration tools for packet filtering and NAT
    ii  iputils-ping                   3:20180629-2                        armhf        Tools to test the reachability of network hosts
    ii  isc-dhcp-client                4.4.1-2                             armhf        DHCP client for automatically obtaining an IP address
    ii  isc-dhcp-common                4.4.1-2                             armhf        common manpages relevant to all of the isc-dhcp packages
    ii  iso-codes                      4.2-1                               all          ISO language, territory, currency, script codes and their translations
    ii  iw                             5.0.1-1                             armhf        tool for configuring Linux wireless devices
    ii  kbd                            2.0.4-4                             armhf        Linux console font and keytable utilities
    ii  keyboard-configuration         1.193~deb10u1                       all          system-wide keyboard preferences
    ii  keyutils                       1.6-6                               armhf        Linux Key Management Utilities
    ii  klibc-utils                    2.0.6-1+rpi1                        armhf        small utilities built with klibc for early boot
    ii  kmod                           26-1                                armhf        tools for managing Linux kernel modules
    ii  less                           487-0.1                             armhf        pager program similar to more
    ii  libacl1:armhf                  2.2.53-4                            armhf        access control list - shared library
    ii  libalgorithm-diff-perl         1.19.03-2                           all          module to find differences between files
    ii  libalgorithm-diff-xs-perl      0.04-5+b1                           armhf        module to find differences between files (XS accelerated)
    ii  libalgorithm-merge-perl        0.08-3                              all          Perl module for three-way merge of textual data
    ii  libapparmor1:armhf             2.13.2-10                           armhf        changehat AppArmor library
    ii  libapt-inst2.0:armhf           1.8.2                               armhf        deb package format runtime library
    ii  libapt-pkg5.0:armhf            1.8.2                               armhf        package management runtime library
    ii  libargon2-1:armhf              0~20171227-0.2                      armhf        memory-hard hashing function - runtime library
    ii  libasan5:armhf                 8.3.0-6+rpi1                        armhf        AddressSanitizer -- a fast memory error detector
    ii  libasound2:armhf               1.1.8-1+rpt1                        armhf        shared library for ALSA applications
    ii  libasound2-data                1.1.8-1+rpt1                        all          Configuration files and profiles for ALSA drivers
    ii  libassuan0:armhf               2.5.2-1                             armhf        IPC library for the GnuPG components
    ii  libatomic1:armhf               8.3.0-6+rpi1                        armhf        support library providing __atomic built-in functions
    ii  libattr1:armhf                 1:2.4.48-4                          armhf        extended attribute handling - shared library
    ii  libaudit-common                1:2.8.4-3                           all          Dynamic library for security auditing - common files
    ii  libaudit1:armhf                1:2.8.4-3                           armhf        Dynamic library for security auditing
    ii  libavahi-common-data:armhf     0.7-4+b1                            armhf        Avahi common data files
    ii  libavahi-common3:armhf         0.7-4+b1                            armhf        Avahi common library
    ii  libavahi-core7:armhf           0.7-4+b1                            armhf        Avahi's embeddable mDNS/DNS-SD library
    ii  libbabeltrace1:armhf           1.5.6-2+deb10u1                     armhf        Babeltrace conversion libraries
    ii  libbind9-161:armhf             1:9.11.5.P4+dfsg-5.1                armhf        BIND9 Shared Library used by BIND
    ii  libbinutils:armhf              2.31.1-16+rpi1                      armhf        GNU binary utilities (private shared library)
    ii  libblkid1:armhf                2.33.1-0.1                          armhf        block device ID library
    ii  libboost-iostreams1.58.0:armhf 1.58.0+dfsg-5.1+rpi1+b4             armhf        Boost.Iostreams Library
    ii  libbsd0:armhf                  0.9.1-2                             armhf        utility functions from BSD systems - shared library
    ii  libbz2-1.0:armhf               1.0.6-9.2~deb10u1                   armhf        high-quality block-sorting file compressor library - runtime
    ii  libc-bin                       2.28-10+rpi1                        armhf        GNU C Library: Binaries
    ii  libc-dev-bin                   2.28-10+rpi1                        armhf        GNU C Library: Development binaries
    ii  libc-l10n                      2.28-10+rpi1                        all          GNU C Library: localization files
    ii  libc6:armhf                    2.28-10+rpi1                        armhf        GNU C Library: Shared libraries
    ii  libc6-dbg:armhf                2.28-10+rpi1                        armhf        GNU C Library: detached debugging symbols
    ii  libc6-dev:armhf                2.28-10+rpi1                        armhf        GNU C Library: Development Libraries and Header Files
    ii  libcap-ng0:armhf               0.7.9-2                             armhf        An alternate POSIX capabilities library
    ii  libcap2:armhf                  1:2.25-2                            armhf        POSIX 1003.1e capabilities (library)
    ii  libcap2-bin                    1:2.25-2                            armhf        POSIX 1003.1e capabilities (utilities)
    ii  libcc1-0:armhf                 8.3.0-6+rpi1                        armhf        GCC cc1 plugin for GDB
    ii  libcom-err2:armhf              1.44.5-1+deb10u2                    armhf        common error description library
    ii  libcryptsetup12:armhf          2:2.1.0-5+deb10u2                   armhf        disk encryption support - shared library
    ii  libcurl4:armhf                 7.64.0-4                            armhf        easy-to-use client-side URL transfer library (OpenSSL flavour)
    ii  libdaemon0:armhf               0.14-7                              armhf        lightweight C library for daemons - runtime library
    ii  libdb5.3:armhf                 5.3.28+dfsg1-0.5                    armhf        Berkeley v5.3 Database Libraries [runtime]
    ii  libdbus-1-3:armhf              1.12.16-1                           armhf        simple interprocess messaging system (library)
    ii  libdebconfclient0:armhf        0.249                               armhf        Debian Configuration Management System (C-implementation library)
    ii  libdevmapper1.02.1:armhf       2:1.02.155-3                        armhf        Linux Kernel Device Mapper userspace library
    ii  libdns-export1104              1:9.11.5.P4+dfsg-5.1                armhf        Exported DNS Shared Library
    ii  libdns1104:armhf               1:9.11.5.P4+dfsg-5.1                armhf        DNS Shared Library used by BIND
    ii  libdpkg-perl                   1.19.7                              all          Dpkg perl modules
    ii  libdw1:armhf                   0.176-1.1                           armhf        library that provides access to the DWARF debug information
    ii  libedit2:armhf                 3.1-20181209-1                      armhf        BSD editline and history libraries
    ii  libelf1:armhf                  0.176-1.1                           armhf        library to read and write ELF files
    ii  libestr0:armhf                 0.1.10-2.1                          armhf        Helper functions for handling strings (lib)
    ii  libevent-2.1-6:armhf           2.1.8-stable-4                      armhf        Asynchronous event notification library
    ii  libexpat1:armhf                2.2.6-2+deb10u1                     armhf        XML parsing C library - runtime library
    ii  libext2fs2:armhf               1.44.5-1+deb10u2                    armhf        ext2/ext3/ext4 file system libraries
    ii  libfakeroot:armhf              1.23-1                              armhf        tool for simulating superuser privileges - shared libraries
    ii  libfastjson4:armhf             0.99.8-2                            armhf        fast json library for C
    ii  libfdisk1:armhf                2.33.1-0.1                          armhf        fdisk partitioning library
    ii  libffi6:armhf                  3.2.1-9                             armhf        Foreign Function Interface library runtime
    ii  libfftw3-single3:armhf         3.3.8-2                             armhf        Library for computing Fast Fourier Transforms - Single precision
    ii  libfile-fcntllock-perl         0.22-3+b4                           armhf        Perl module for file locking with fcntl(2)
    ii  libfreetype6:armhf             2.9.1-3+deb10u1                     armhf        FreeType 2 font engine, shared library files
    ii  libfreetype6-dev:armhf         2.9.1-3+deb10u1                     armhf        FreeType 2 font engine, development files
    ii  libfribidi0:armhf              1.0.5-3.1+deb10u1                   armhf        Free Implementation of the Unicode BiDi algorithm
    ii  libfstrm0:armhf                0.4.0-1                             armhf        Frame Streams (fstrm) library
    ii  libftdi1-2:armhf               1.4-1+b2                            armhf        Library to control and program the FTDI USB controllers
    ii  libfuse2:armhf                 2.9.9-1                             armhf        Filesystem in Userspace (library)
    ii  libgcc-8-dev:armhf             8.3.0-6+rpi1                        armhf        GCC support library (development files)
    ii  libgcc1:armhf                  1:8.3.0-6+rpi1                      armhf        GCC support library
    ii  libgcrypt20:armhf              1.8.4-5                             armhf        LGPL Crypto library - runtime library
    ii  libgdbm-compat4:armhf          1.18.1-4                            armhf        GNU dbm database routines (legacy support runtime version)
    ii  libgdbm6:armhf                 1.18.1-4                            armhf        GNU dbm database routines (runtime version)
    ii  libgeoip1:armhf                1.6.12-1                            armhf        non-DNS IP-to-country resolver library
    ii  libglib2.0-0:armhf             2.58.3-2+deb10u2                    armhf        GLib library of C routines
    ii  libglib2.0-data                2.58.3-2+deb10u2                    all          Common files for GLib library
    ii  libgmp10:armhf                 2:6.1.2+dfsg-4                      armhf        Multiprecision arithmetic library
    ii  libgnutls30:armhf              3.6.7-4                             armhf        GNU TLS library - main runtime library
    ii  libgomp1:armhf                 8.3.0-6+rpi1                        armhf        GCC OpenMP (GOMP) support library
    ii  libgpg-error0:armhf            1.35-1                              armhf        GnuPG development runtime library
    ii  libgpm2:armhf                  1.20.7-5                            armhf        General Purpose Mouse - shared library
    ii  libgssapi-krb5-2:armhf         1.17-3                              armhf        MIT Kerberos runtime libraries - krb5 GSS-API Mechanism
    ii  libhogweed4:armhf              3.4.1-1                             armhf        low level cryptographic library (public-key cryptos)
    ii  libicu63:armhf                 63.1-6                              armhf        International Components for Unicode
    ii  libident                       0.22-3.1                            armhf        simple RFC1413 client library - runtime
    ii  libidn11:armhf                 1.33-2.2                            armhf        GNU Libidn library, implementation of IETF IDN specifications
    ii  libidn2-0:armhf                2.0.5-1+deb10u1                     armhf        Internationalized domain names (IDNA2008/TR46) library
    ii  libip4tc0:armhf                1.8.2-4                             armhf        netfilter libip4tc library
    ii  libip6tc0:armhf                1.8.2-4                             armhf        netfilter libip6tc library
    ii  libiptc0:armhf                 1.8.2-4                             armhf        netfilter libiptc library
    ii  libisc-export1100:armhf        1:9.11.5.P4+dfsg-5.1                armhf        Exported ISC Shared Library
    ii  libisc1100:armhf               1:9.11.5.P4+dfsg-5.1                armhf        ISC Shared Library used by BIND
    ii  libisccc161:armhf              1:9.11.5.P4+dfsg-5.1                armhf        Command Channel Library used by BIND
    ii  libisccfg163:armhf             1:9.11.5.P4+dfsg-5.1                armhf        Config File Handling Library used by BIND
    ii  libisl19:armhf                 0.20-2                              armhf        manipulating sets and relations of integer points bounded by linear constraints
    ii  libiw30:armhf                  30~pre9-13                          armhf        Wireless tools - library
    ii  libjim0.77:armhf               0.77+dfsg0-3                        armhf        small-footprint implementation of Tcl - shared library
    ii  libjpeg62-turbo:armhf          1:1.5.2-2+b1                        armhf        libjpeg-turbo JPEG runtime library
    ii  libjson-c3:armhf               0.12.1+ds-2                         armhf        JSON manipulation library - shared library
    ii  libk5crypto3:armhf             1.17-3                              armhf        MIT Kerberos runtime libraries - Crypto Library
    ii  libkeyutils1:armhf             1.6-6                               armhf        Linux Key Management Utilities (library)
    ii  libklibc:armhf                 2.0.6-1+rpi1                        armhf        minimal libc subset for use with initramfs
    ii  libkmod2:armhf                 26-1                                armhf        libkmod shared library
    ii  libkrb5-3:armhf                1.17-3                              armhf        MIT Kerberos runtime libraries
    ii  libkrb5support0:armhf          1.17-3                              armhf        MIT Kerberos runtime libraries - Support library
    ii  libksba8:armhf                 1.3.5-2                             armhf        X.509 and CMS support library
    ii  libldap-2.4-2:armhf            2.4.47+dfsg-3+rpi1+deb10u1          armhf        OpenLDAP libraries
    ii  libldap-common                 2.4.47+dfsg-3+rpi1+deb10u1          all          OpenLDAP common files for libraries
    ii  liblmdb0:armhf                 0.9.22-1                            armhf        Lightning Memory-Mapped Database shared library
    ii  liblocale-gettext-perl         1.07-3+b3                           armhf        module using libc functions for internationalization in Perl
    ii  liblognorm5:armhf              2.0.5-1                             armhf        log normalizing library
    ii  libluajit-5.1-2:armhf          2.1.0~beta3+dfsg-5.1                armhf        Just in time compiler for Lua - library version
    ii  libluajit-5.1-common           2.1.0~beta3+dfsg-5.1                all          Just in time compiler for Lua - common files
    ii  liblwres161:armhf              1:9.11.5.P4+dfsg-5.1                armhf        Lightweight Resolver Library used by BIND
    ii  liblz4-1:armhf                 1.8.3-1                             armhf        Fast LZ compression algorithm library - runtime
    ii  liblzma5:armhf                 5.2.4-1                             armhf        XZ-format compression library
    ii  libmagic-mgc                   1:5.35-4+deb10u1                    armhf        File type determination library using "magic" numbers (compiled magic file)
    ii  libmagic1:armhf                1:5.35-4+deb10u1                    armhf        Recognize the type of data in a file using "magic" numbers - library
    ii  libmnl-dev                     1.0.4-2                             armhf        minimalistic Netlink communication library (devel)
    ii  libmnl0:armhf                  1.0.4-2                             armhf        minimalistic Netlink communication library
    ii  libmount1:armhf                2.33.1-0.1                          armhf        device mounting library
    ii  libmpc3:armhf                  1.1.0-1                             armhf        multiple precision complex floating-point library
    ii  libmpdec2:armhf                2.4.2-2                             armhf        library for decimal floating point arithmetic (runtime library)
    ii  libmpfr6:armhf                 4.0.2-1                             armhf        multiple precision floating-point computation
    ii  libmtp-common                  1.1.16-2                            all          Media Transfer Protocol (MTP) common files
    ii  libmtp-runtime                 1.1.16-2                            armhf        Media Transfer Protocol (MTP) runtime tools
    ii  libmtp9:armhf                  1.1.16-2                            armhf        Media Transfer Protocol (MTP) library
    ii  libncurses6:armhf              6.1+20181013-2+deb10u2              armhf        shared libraries for terminal handling
    ii  libncursesw5:armhf             6.1+20181013-2+deb10u2              armhf        shared libraries for terminal handling (wide character legacy version)
    ii  libncursesw6:armhf             6.1+20181013-2+deb10u2              armhf        shared libraries for terminal handling (wide character support)
    ii  libnetfilter-conntrack3:armhf  1.0.7-1                             armhf        Netfilter netlink-conntrack library
    ii  libnettle6:armhf               3.4.1-1                             armhf        low level cryptographic library (symmetric and one-way cryptos)
    ii  libnewt0.52:armhf              0.52.20-8                           armhf        Not Erik's Windowing Toolkit - text mode windowing with slang
    ii  libnfnetlink0:armhf            1.0.1-3                             armhf        Netfilter netlink library
    ii  libnfsidmap2:armhf             0.25-5.1                            armhf        NFS idmapping library
    ii  libnftnl11:armhf               1.1.2-2                             armhf        Netfilter nftables userspace API library
    ii  libnghttp2-14:armhf            1.36.0-2+deb10u1                    armhf        library implementing HTTP/2 protocol (shared library)
    ii  libnl-3-200:armhf              3.4.0-1                             armhf        library for dealing with netlink sockets
    ii  libnl-genl-3-200:armhf         3.4.0-1                             armhf        library for dealing with netlink sockets - generic netlink
    ii  libnl-route-3-200:armhf        3.4.0-1                             armhf        library for dealing with netlink sockets - route interface
    ii  libnpth0:armhf                 1.6-1                               armhf        replacement for GNU Pth using system threads
    ii  libnss-mdns:armhf              0.14.1-1+b5                         armhf        NSS module for Multicast DNS name resolution
    ii  libntfs-3g883                  1:2017.3.23AR.3-3                   armhf        read/write NTFS driver for FUSE (runtime library)
    ii  libp11-kit0:armhf              0.23.15-2                           armhf        library for loading and coordinating access to PKCS#11 modules - runtime
    ii  libpam-chksshpwd:armhf         1.3.1-5+rpt1                        armhf        PAM module to enable SSH password checking support
    ii  libpam-modules:armhf           1.3.1-5+rpt1                        armhf        Pluggable Authentication Modules for PAM
    ii  libpam-modules-bin             1.3.1-5+rpt1                        armhf        Pluggable Authentication Modules for PAM - helper binaries
    ii  libpam-runtime                 1.3.1-5+rpt1                        all          Runtime support for the PAM library
    ii  libpam-systemd:armhf           241-7~deb10u2+rpi1                  armhf        system and service manager - PAM module
    ii  libpam0g:armhf                 1.3.1-5+rpt1                        armhf        Pluggable Authentication Modules library
    ii  libparted2:armhf               3.2-25                              armhf        disk partition manipulator - shared library
    ii  libpci3:armhf                  1:3.5.2-1                           armhf        Linux PCI Utilities (shared library)
    ii  libpcre2-8-0:armhf             10.32-5                             armhf        New Perl Compatible Regular Expression Library- 8 bit runtime files
    ii  libpcre2-posix0:armhf          10.32-5                             armhf        New Perl Compatible Regular Expression Library - posix-compatible runtime files
    ii  libpcre3:armhf                 2:8.39-12                           armhf        Old Perl 5 Compatible Regular Expression Library - runtime files
    ii  libpcsclite1:armhf             1.8.24-1                            armhf        Middleware to access a smart card using PC/SC (library)
    ii  libperl5.28:armhf              5.28.1-6                            armhf        shared Perl library
    ii  libpipeline1:armhf             1.5.1-2                             armhf        pipeline manipulation library
    ii  libpng-dev:armhf               1.6.36-6                            armhf        PNG library - development (version 1.6)
    ii  libpng-tools                   1.6.36-6                            armhf        PNG library - tools (version 1.6)
    ii  libpng16-16:armhf              1.6.36-6                            armhf        PNG library - runtime (version 1.6)
    ii  libpolkit-agent-1-0:armhf      0.105-25                            armhf        PolicyKit Authentication Agent API
    ii  libpolkit-backend-1-0:armhf    0.105-25                            armhf        PolicyKit backend API
    ii  libpolkit-gobject-1-0:armhf    0.105-25                            armhf        PolicyKit Authorization API
    ii  libpopt0:armhf                 1.16-12                             armhf        lib for parsing cmdline parameters
    ii  libprocps7:armhf               2:3.3.15-2                          armhf        library for accessing process information from /proc
    ii  libprotobuf-c1:armhf           1.3.1-1+b1                          armhf        Protocol Buffers C shared library (protobuf-c)
    ii  libpsl5:armhf                  0.20.2-2                            armhf        Library for Public Suffix List (shared libraries)
    ii  libpython-stdlib:armhf         2.7.16-1                            armhf        interactive high-level object-oriented language (Python2)
    ii  libpython2-stdlib:armhf        2.7.16-1                            armhf        interactive high-level object-oriented language (Python2)
    ii  libpython2.7-minimal:armhf     2.7.16-2+deb10u1                    armhf        Minimal subset of the Python language (version 2.7)
    ii  libpython2.7-stdlib:armhf      2.7.16-2+deb10u1                    armhf        Interactive high-level object-oriented language (standard library, version 2.7)
    ii  libpython3-stdlib:armhf        3.7.3-1                             armhf        interactive high-level object-oriented language (default python3 version)
    ii  libpython3.7:armhf             3.7.3-2                             armhf        Shared Python runtime library (version 3.7)
    ii  libpython3.7-minimal:armhf     3.7.3-2                             armhf        Minimal subset of the Python language (version 3.7)
    ii  libpython3.7-stdlib:armhf      3.7.3-2                             armhf        Interactive high-level object-oriented language (standard library, version 3.7)
    ii  libraspberrypi-bin             1.20200205-1                        armhf        Miscellaneous Raspberry Pi utilities
    ii  libraspberrypi-dev             1.20200205-1                        armhf        EGL/GLES/OpenVG/etc. libraries for the Raspberry Pi's VideoCore IV (headers)
    ii  libraspberrypi-doc             1.20200205-1                        armhf        EGL/GLES/OpenVG/etc. libraries for the Raspberry Pi's VideoCore IV (headers)
    ii  libraspberrypi0                1.20200205-1                        armhf        EGL/GLES/OpenVG/etc. libraries for the Raspberry Pi's VideoCore IV
    ii  libreadline6:armhf             6.3-9                               armhf        GNU readline and history libraries, run-time libraries
    ii  libreadline7:armhf             7.0-5                               armhf        GNU readline and history libraries, run-time libraries
    ii  librtmp1:armhf                 2.4+20151223.gitfa8646d.1-2         armhf        toolkit for RTMP streams (shared library)
    ii  libsamplerate0:armhf           0.1.9-2                             armhf        Audio sample rate conversion library
    ii  libsasl2-2:armhf               2.1.27+dfsg-1+deb10u1               armhf        Cyrus SASL - authentication abstraction library
    ii  libsasl2-modules-db:armhf      2.1.27+dfsg-1+deb10u1               armhf        Cyrus SASL - pluggable authentication modules (DB)
    ii  libseccomp2:armhf              2.3.3-4                             armhf        high level interface to Linux seccomp filter
    ii  libselinux1:armhf              2.8-1+b1                            armhf        SELinux runtime shared libraries
    ii  libsemanage-common             2.8-2                               all          Common files for SELinux policy management libraries
    ii  libsemanage1:armhf             2.8-2                               armhf        SELinux policy management library
    ii  libsepol1:armhf                2.8-1                               armhf        SELinux library for manipulating binary security policies
    ii  libsigc++-1.2-5c2              1.2.7-2+b1                          armhf        type-safe Signal Framework for C++ - runtime
    ii  libslang2:armhf                2.3.2-2                             armhf        S-Lang programming library - runtime version
    ii  libsmartcols1:armhf            2.33.1-0.1                          armhf        smart column output alignment library
    ii  libsqlite3-0:armhf             3.27.2-3                            armhf        SQLite 3 shared library
    ii  libss2:armhf                   1.44.5-1+deb10u2                    armhf        command-line interface parsing library
    ii  libssh2-1:armhf                1.8.0-2.1                           armhf        SSH2 client-side library
    ii  libssl1.1:armhf                1.1.1d-0+deb10u2+rpt1               armhf        Secure Sockets Layer toolkit - shared libraries
    ii  libstdc++-8-dev:armhf          8.3.0-6+rpi1                        armhf        GNU Standard C++ Library v3 (development files)
    ii  libstdc++6:armhf               8.3.0-6+rpi1                        armhf        GNU Standard C++ Library v3
    ii  libsystemd0:armhf              241-7~deb10u2+rpi1                  armhf        systemd utility library
    ii  libtalloc2:armhf               2.1.14-2                            armhf        hierarchical pool based memory allocator
    ii  libtasn1-6:armhf               4.13-3                              armhf        Manage ASN.1 structures (runtime)
    ii  libtext-charwidth-perl         0.04-7.1+b1                         armhf        get display widths of characters on the terminal
    ii  libtext-iconv-perl             1.7-5+b10                           armhf        converts between character sets in Perl
    ii  libtext-wrapi18n-perl          0.06-7.1                            all          internationalized substitute of Text::Wrap
    ii  libtinfo5:armhf                6.1+20181013-2+deb10u2              armhf        shared low-level terminfo library (legacy version)
    ii  libtinfo6:armhf                6.1+20181013-2+deb10u2              armhf        shared low-level terminfo library for terminal handling
    ii  libtirpc-common                1.1.4-0.4                           all          transport-independent RPC library - common files
    ii  libtirpc3:armhf                1.1.4-0.4                           armhf        transport-independent RPC library
    ii  libubsan1:armhf                8.3.0-6+rpi1                        armhf        UBSan -- undefined behaviour sanitizer (runtime)
    ii  libuchardet0:armhf             0.0.6-3                             armhf        universal charset detection library - shared library
    ii  libudev0:armhf                 175-7.2                             armhf        libudev shared library
    ii  libudev1:armhf                 241-7~deb10u2+rpi1                  armhf        libudev shared library
    ii  libunistring2:armhf            0.9.10-1                            armhf        Unicode string library for C
    ii  libusb-0.1-4:armhf             2:0.1.12-32                         armhf        userspace USB programming library
    ii  libusb-1.0-0:armhf             2:1.0.22-2                          armhf        userspace USB programming library
    ii  libuuid1:armhf                 2.33.1-0.1                          armhf        Universally Unique ID library
    ii  libv4l-0:armhf                 1.16.3-3                            armhf        Collection of video4linux support libraries
    ii  libv4l2rds0:armhf              1.16.3-3                            armhf        Video4Linux Radio Data System (RDS) decoding library
    ii  libv4lconvert0:armhf           1.16.3-3                            armhf        Video4linux frame format conversion library
    ii  libwbclient0:armhf             2:4.9.5+dfsg-5+deb10u1+rpi1         armhf        Samba winbind client library
    ii  libwrap0:armhf                 7.6.q-28                            armhf        Wietse Venema's TCP wrappers library
    ii  libx11-6:armhf                 2:1.6.7-1                           armhf        X11 client-side library
    ii  libx11-data                    2:1.6.7-1                           all          X11 client-side library
    ii  libxau6:armhf                  1:1.0.8-1+b2                        armhf        X11 authorisation library
    ii  libxcb1:armhf                  1.13.1-2                            armhf        X C Binding
    ii  libxdmcp6:armhf                1:1.1.2-3                           armhf        X11 Display Manager Control Protocol library
    ii  libxext6:armhf                 2:1.3.3-1+b2                        armhf        X11 miscellaneous extension library
    ii  libxml2:armhf                  2.9.4+dfsg1-7+b3                    armhf        GNOME XML library
    ii  libxmuu1:armhf                 2:1.1.2-2+b3                        armhf        X11 miscellaneous micro-utility library
    ii  libxtables12:armhf             1.8.2-4                             armhf        netfilter xtables library
    ii  libzstd1:armhf                 1.3.8+dfsg-3+rpi1                   armhf        fast lossless compression algorithm
    ii  linux-base                     4.6                                 all          Linux image base package
    ii  linux-libc-dev:armhf           4.18.20-2+rpi1                      armhf        Linux support headers for userspace development
    ii  locales                        2.28-10+rpi1                        all          GNU C Library: National Language (locale) data [support]
    ii  login                          1:4.5-1.1                           armhf        system login tools
    ii  logrotate                      3.14.0-4                            armhf        Log rotation utility
    ii  lsb-base                       10.2019051400+rpi1                  all          Linux Standard Base init script functionality
    ii  lsb-release                    10.2019051400+rpi1                  all          Linux Standard Base version reporting utility
    ii  lua5.1                         5.1.5-8.1+b1                        armhf        Simple, extensible, embeddable programming language
    ii  luajit                         2.1.0~beta3+dfsg-5.1                armhf        Just in time compiler for Lua programming language version 5.1
    ii  make                           4.2.1-1.2                           armhf        utility for directing compilation
    ii  man-db                         2.8.5-2                             armhf        on-line manual pager
    ii  manpages                       4.16-2                              all          Manual pages about using a GNU/Linux system
    ii  manpages-dev                   4.16-2                              all          Manual pages about using GNU/Linux for development
    ii  mawk                           1.3.3-17                            armhf        a pattern scanning and text processing language
    ii  mime-support                   3.62                                all          MIME files 'mime.types' & 'mailcap', and support programs
    ii  mount                          2.33.1-0.1                          armhf        tools for mounting and manipulating filesystems
    ii  multiarch-support              2.28-10+rpi1                        armhf        Transitional package to ensure multiarch compatibility
    ii  nano                           3.2-3                               armhf        small, friendly text editor inspired by Pico
    ii  ncdu                           1.13-1                              armhf        ncurses disk usage viewer
    ii  ncurses-base                   6.1+20181013-2+deb10u2              all          basic terminal type definitions
    ii  ncurses-bin                    6.1+20181013-2+deb10u2              armhf        terminal-related programs and man pages
    ii  ncurses-term                   6.1+20181013-2+deb10u2              all          additional terminal type definitions
    ii  net-tools                      1.60+git20180626.aebd88e-1          armhf        NET-3 networking toolkit
    ii  netbase                        5.6                                 all          Basic TCP/IP networking system
    ii  netcat-openbsd                 1.195-2                             armhf        TCP/IP swiss army knife
    ii  netcat-traditional             1.10-41.1                           armhf        TCP/IP swiss army knife
    ii  nfs-common                     1:1.3.4-2.5                         armhf        NFS support files common to client and server
    ii  ntfs-3g                        1:2017.3.23AR.3-3                   armhf        read/write NTFS driver for FUSE
    ii  openresolv                     3.8.0-1                             armhf        management framework for resolv.conf
    ii  openssh-client                 1:7.9p1-10+deb10u1                  armhf        secure shell (SSH) client, for secure access to remote machines
    ii  openssh-server                 1:7.9p1-10+deb10u1                  armhf        secure shell (SSH) server, for secure access from remote machines
    ii  openssh-sftp-server            1:7.9p1-10+deb10u1                  armhf        secure shell (SSH) sftp server module, for SFTP access from remote machines
    ii  openssl                        1.1.1d-0+deb10u2+rpt1               armhf        Secure Sockets Layer toolkit - cryptographic utility
    ii  parted                         3.2-25                              armhf        disk partition manipulator
    ii  passwd                         1:4.5-1.1                           armhf        change and administer password and group data
    ii  patch                          2.7.6-3+deb10u1                     armhf        Apply a diff file to an original
    ii  paxctld                        1.2.1-1                             armhf        Daemon to automatically set appropriate PaX flags
    ii  pciutils                       1:3.5.2-1                           armhf        Linux PCI Utilities
    ii  perl                           5.28.1-6                            armhf        Larry Wall's Practical Extraction and Report Language
    ii  perl-base                      5.28.1-6                            armhf        minimal Perl system
    ii  perl-modules-5.28              5.28.1-6                            all          Core Perl modules
    ii  pi-bluetooth                   0.1.12                              all          Raspberry Pi 3 bluetooth
    ii  pigz                           2.4-1                               armhf        Parallel Implementation of GZip
    ii  pinentry-curses                1.1.0-2                             armhf        curses-based PIN or pass-phrase entry dialog for GnuPG
    ii  pkg-config                     0.29-6                              armhf        manage compile and link flags for libraries
    ii  policykit-1                    0.105-25                            armhf        framework for managing administrative policies and privileges
    ii  procps                         2:3.3.15-2                          armhf        /proc file system utilities
    ii  psmisc                         23.2-1                              armhf        utilities that use the proc file system
    ii  publicsuffix                   20190415.1030-1                     all          accurate, machine-readable list of domain name suffixes
    ii  python                         2.7.16-1                            armhf        interactive high-level object-oriented language (Python2 version)
    ii  python-apt-common              1.8.4.1                             all          Python interface to libapt-pkg (locales)
    ii  python-minimal                 2.7.16-1                            armhf        minimal subset of the Python2 language
    ii  python-rpi.gpio                0.7.0~buster-1                      armhf        Python GPIO module for Raspberry Pi
    ii  python2                        2.7.16-1                            armhf        interactive high-level object-oriented language (Python2 version)
    ii  python2-minimal                2.7.16-1                            armhf        minimal subset of the Python2 language
    ii  python2.7                      2.7.16-2+deb10u1                    armhf        Interactive high-level object-oriented language (version 2.7)
    ii  python2.7-minimal              2.7.16-2+deb10u1                    armhf        Minimal subset of the Python language (version 2.7)
    ii  python3                        3.7.3-1                             armhf        interactive high-level object-oriented language (default python3 version)
    ii  python3-apt                    1.8.4.1                             armhf        Python 3 interface to libapt-pkg
    ii  python3-certifi                2018.8.24-1                         all          root certificates for validating SSL certs and verifying TLS hosts (python3)
    ii  python3-chardet                3.0.4-3                             all          universal character encoding detector for Python3
    ii  python3-debconf                1.5.71                              all          interact with debconf from Python 3
    ii  python3-idna                   2.6-1                               all          Python IDNA2008 (RFC 5891) handling (Python 3)
    ii  python3-minimal                3.7.3-1                             armhf        minimal subset of the Python language (default python3 version)
    ii  python3-pkg-resources          40.8.0-1                            all          Package Discovery and Resource Access using pkg_resources
    ii  python3-requests               2.21.0-1                            all          elegant and simple HTTP library for Python3, built for human beings
    ii  python3-six                    1.12.0-1                            all          Python 2 and 3 compatibility library (Python 3 interface)
    ii  python3-urllib3                1.24.1-1                            all          HTTP library with thread-safe connection pooling for Python3
    ii  python3.7                      3.7.3-2                             armhf        Interactive high-level object-oriented language (version 3.7)
    ii  python3.7-minimal              3.7.3-2                             armhf        Minimal subset of the Python language (version 3.7)
    ii  raspberrypi-bootloader         1.20200205-1                        armhf        Raspberry Pi bootloader
    ii  raspberrypi-kernel             1.20200205-1                        armhf        Raspberry Pi bootloader
    ii  raspberrypi-net-mods           1.3.0                               all          Network configuration for the Raspberry Pi UI
    ii  raspberrypi-sys-mods           20191105                            armhf        System tweaks for the Raspberry Pi
    ii  raspbian-archive-keyring       20120528.2                          all          GnuPG archive keys of the raspbian archive
    ii  raspi-config                   20200205                            all          Raspberry Pi configuration tool
    ii  raspi-copies-and-fills         0.13                                armhf        ARM-accelerated versions of selected functions from string.h
    ii  readline-common                7.0-5                               all          GNU readline and history libraries, common files
    ii  rfkill                         2.33.1-0.1                          armhf        tool for enabling and disabling wireless devices
    ii  rng-tools                      2-unofficial-mt.14-1                armhf        Daemon to use a Hardware TRNG
    ii  rpcbind                        1.2.5-0.3+deb10u1                   armhf        converts RPC program numbers into universal addresses
    ii  rpi-eeprom                     4.0-1                               armhf        Raspberry Pi 4 boot EEPROM updater
    ii  rpi-eeprom-images              4.0-1                               all          Raspberry Pi 4 boot EEPROM images
    ii  rpi-update                     20140705                            all          Raspberry Pi firmware updating tool
    ii  rsync                          3.1.3-6                             armhf        fast, versatile, remote (and local) file-copying tool
    ii  rsyslog                        8.1901.0-1                          armhf        reliable system and kernel logging daemon
    ii  sed                            4.7-1                               armhf        GNU stream editor for filtering/transforming text
    ii  sensible-utils                 0.0.12                              all          Utilities for sensible alternative selection
    ii  shared-mime-info               1.10-1                              armhf        FreeDesktop.org shared MIME database and spec
    ii  ssh                            1:7.9p1-10+deb10u1                  all          secure shell client and server (metapackage)
    ii  ssh-import-id                  5.7-1                               all          securely retrieve an SSH public key and install it locally
    ii  strace                         4.26-0.2                            armhf        System call tracer
    ii  sudo                           1.8.27-1+deb10u1                    armhf        Provide limited super user privileges to specific users
    ii  systemd                        241-7~deb10u2+rpi1                  armhf        system and service manager
    ii  systemd-sysv                   241-7~deb10u2+rpi1                  armhf        system and service manager - SysV links
    ii  sysvinit-utils                 2.93-8                              armhf        System-V-like utilities
    ii  tar                            1.30+dfsg-6                         armhf        GNU version of the tar archiving utility
    ii  tasksel                        3.53                                all          tool for selecting tasks for installation on Debian systems
    ii  tasksel-data                   3.53                                all          official tasks used for installation of Debian systems
    ii  traceroute                     1:2.1.0-2                           armhf        Traces the route taken by packets over an IPv4/IPv6 network
    ii  triggerhappy                   0.5.0-1                             armhf        global hotkey daemon for Linux
    ii  tzdata                         2019c-0+deb10u1                     all          time zone and daylight-saving time data
    ii  ucf                            3.0038+nmu1                         all          Update Configuration File(s): preserve user changes to config files
    ii  udev                           241-7~deb10u2+rpi1                  armhf        /dev/ and hotplug management daemon
    ii  unzip                          6.0-23+deb10u1                      armhf        De-archiver for .zip files
    ii  usb-modeswitch                 2.5.2+repack0-2                     armhf        mode switching tool for controlling "flip flop" USB devices
    ii  usb-modeswitch-data            20170806-2                          all          mode switching data for usb-modeswitch
    ii  usb.ids                        2019.07.27-0+deb10u1                all          USB ID Repository
    ii  usbutils                       1:010-3                             armhf        Linux USB utilities
    ii  util-linux                     2.33.1-0.1                          armhf        miscellaneous system utilities
    ii  v4l-utils                      1.16.3-3                            armhf        Collection of command line video4linux utilities
    ii  vim-common                     2:8.1.0875-5                        all          Vi IMproved - Common files
    ii  vim-tiny                       2:8.1.0875-5                        armhf        Vi IMproved - enhanced vi editor - compact version
    ii  vl805fw                        0.2                                 all          Firmware loader for VL805 USB host controller
    ii  wget                           1.20.1-1.1                          armhf        retrieves files from the web
    ii  whiptail                       0.52.20-8                           armhf        Displays user-friendly dialog boxes from shell scripts
    ii  wireless-regdb                 2018.05.09-0~rpt1                   all          wireless regulatory database
    ii  wireless-tools                 30~pre9-13                          armhf        Tools for manipulating Linux Wireless Extensions
    ii  wpasupplicant                  2:2.7+git20190128+0c1e29f-6+deb10u1 armhf        client support for WPA and WPA2 (IEEE 802.11i)
    ii  xauth                          1:1.0.10-1                          armhf        X authentication utility
    ii  xdg-user-dirs                  0.17-2                              armhf        tool to manage well known user directories
    ii  xkb-data                       2.26-2                              all          X Keyboard Extension (XKB) configuration data
    ii  xxd                            2:8.1.0875-5                        armhf        tool to make (or reverse) a hex dump
    ii  xz-utils                       5.2.4-1                             armhf        XZ-format compression utilities
    ii  zlib1g:armhf                   1:1.2.11.dfsg-1                     armhf        compression library - runtime
    ii  zlib1g-dev:armhf               1:1.2.11.dfsg-1                     armhf        compression library - development

## ファイル構成(2 階層)

    # ls *$x
    bin:
    bash     bzip2         cp             dumpkeys   fusermount  keyctl    login        more            netcat         ntfsfix       pidof     rmdir      su                        systemd-sysusers                uname          zegrep
    bunzip2  bzip2recover  cpio           echo       grep        kill      loginctl     mount           netstat        ntfsinfo      ping      rnano      sync                      systemd-tmpfiles                uncompress     zfgrep
    busybox  bzless        dash           ed         gunzip      kmod      lowntfs-3g   mountpoint      networkctl     ntfsls        ping4     run-parts  systemctl                 systemd-tty-ask-password-agent  unicode_start  zforce
    bzcat    bzmore        date           egrep      gzexe       less      ls           mt              nisdomainname  ntfsmove      ping6     sed        systemd                   tar                             vdir           zgrep
    bzcmp    cat           dd             false      gzip        lessecho  lsblk        mt-gnu          ntfs-3g        ntfsrecover   ps        setfont    systemd-ask-password      tempfile                        wdctl          zless
    bzdiff   chgrp         df             fbset      hciconfig   lessfile  lsmod        mv              ntfs-3g.probe  ntfssecaudit  pwd       setupcon   systemd-escape            touch                           which          zmore
    bzegrep  chmod         dir            fgconsole  hostname    lesskey   mkdir        nano            ntfscat        ntfstruncate  rbash     sh         systemd-hwdb              true                            ypdomainname   znew
    bzexe    chown         dmesg          fgrep      ip          lesspipe  mknod        nc              ntfscluster    ntfsusermap   readlink  sleep      systemd-inhibit           udevadm                         zcat
    bzfgrep  chvt          dnsdomainname  findmnt    journalctl  ln        mktemp       nc.openbsd      ntfscmp        ntfswipe      red       ss         systemd-machine-id-setup  ulockmgr_server                 zcmp
    bzgrep   con2fbmap     domainname     fuser      kbd_mode    loadkeys  modeline2fb  nc.traditional  ntfsfallocate  openvt        rm        stty       systemd-notify            umount                          zdiff

    boot:

    dev:
    console  core  fd  full  mqueue  null  ptmx  pts  random  shm  stderr  stdin  stdout  tty  urandom  zero

    etc:
    X11                     ca-certificates.conf  debian_version     gai.conf     ifplugd          ld.so.conf.d    machine-id      mtab           perl       rc1.d             rmt           ssh          triggerhappy
    adduser.conf            calendar              default            gdb          init             ld.so.preload   magic           nanorc         polkit-1   rc2.d             rpc           ssl          ucf.conf
    alternatives            cifs-utils            deluser.conf       groff        init.d           ldap            magic.mime      netconfig      ppp        rc3.d             rpi-issue     subgid       udev
    apparmor.d              console-setup         dhcp               group        initramfs-tools  libaudit.conf   mailcap         network        profile    rc4.d             rsyslog.conf  subuid       ufw
    apt                     cron.d                dhcpcd.conf        gshadow      inputrc          libnl-3         mailcap.order   networks       profile.d  rc5.d             rsyslog.d     sudoers      update-motd.d
    avahi                   cron.daily            dphys-swapfile     gss          insserv.conf.d   locale.alias    manpath.config  nsswitch.conf  protocols  rc6.d             securetty     sudoers.d    usb_modeswitch.conf
    bash.bashrc             cron.hourly           dpkg               host.conf    iproute2         locale.gen      mime.types      opt            python     rcS.d             security      sysctl.conf  usb_modeswitch.d
    bash_completion         cron.monthly          environment        hostname     issue            localtime       mke2fs.conf     os-release     python2.7  request-key.conf  selinux       sysctl.d     vim
    bindresvport.blacklist  cron.weekly           fake-hwclock.data  hosts        issue.net        logcheck        modprobe.d      pam.conf       python3    request-key.d     services      systemd      wgetrc
    binfmt.d                crontab               fb.modes           hosts.allow  kernel           login.defs      modules         pam.d          python3.7  resolv.conf       shadow        terminfo     wpa_supplicant
    bluetooth               dbus-1                fstab              hosts.deny   ld.so.cache      logrotate.conf  modules-load.d  passwd         rc.local   resolvconf        shells        timezone     xattr.conf
    ca-certificates         debconf.conf          fuse.conf          idmapd.conf  ld.so.conf       logrotate.d     motd            paxctld.conf   rc0.d      resolvconf.conf   skel          tmpfiles.d   xdg

    home:
    pi

    lib:
    arm-linux-gnueabihf  console-setup  cpp  crda  dhcpcd  firmware  ifupdown  init  klibc-fAGGTaZfOmYXUytsXgfSuL5MT48.so  ld-linux-armhf.so.3  ld-linux.so.3  lsb  modprobe.d  modules  resolvconf  systemd  terminfo  udev

    lost+found:

    media:

    mnt:

    opt:
    vc

    proc:
    1     buddyinfo  cmdline    cpuinfo  diskstats  execdomains  fs          ioports   kcore      kmsg         kpageflags  meminfo  mounts  net           sched_debug  softirqs  sys            thread-self  uptime       vmstat
    139   bus        config.gz  crypto   dma        fb           interrupts  irq       key-users  kpagecgroup  loadavg     misc     mpt     pagetypeinfo  self         stat      sysrq-trigger  timer_list   version      zoneinfo
    acpi  cgroups    consoles   devices  driver     filesystems  iomem       kallsyms  keys       kpagecount   locks       modules  mtrr    partitions    slabinfo     swaps     sysvipc        tty          vmallocinfo

    root:

    run:
    lock  mount  utmp

    sbin:
    agetty         ctrlaltdel       dphys-swapfile  fsck          getcap         ip                 iwevent           mii-tool     mkfs.ntfs         mount.ntfs     partprobe    rmmod         shutdown           tipc
    badblocks      debugfs          dumpe2fs        fsck.cramfs   getpcaps       ip6tables          iwgetid           mkdosfs      mkfs.vfat         mount.ntfs-3g  paxctld      route         slattach           tune2fs
    blkdeactivate  depmod           e2fsck          fsck.ext2     getty          ip6tables-restore  iwlist            mke2fs       mkhomedir_helper  nameif         pivot_root   rpc.statd     sm-notify          udevadm
    blkdiscard     devlink          e2image         fsck.ext3     halt           ip6tables-save     iwpriv            mkfs         mkntfs            ntfsclone      plipconfig   rpcbind       start-stop-daemon  umount.nfs
    blkid          dhclient         e2label         fsck.ext4     hwclock        ipmaddr            iwspy             mkfs.bfs     mkswap            ntfscp         poweroff     rtacct        sulogin            umount.nfs4
    blkzone        dhclient-script  e2mmpstatus     fsck.fat      ifconfig       iptables           kbdrate           mkfs.cramfs  modinfo           ntfslabel      rarp         rtmon         swaplabel          unix_chkpwd
    blockdev       dhcpcd           e2undo          fsck.minix    ifdown         iptables-restore   key.dns_resolver  mkfs.ext2    modprobe          ntfsresize     raw          runlevel      swapoff            unix_update
    bridge         dhcpcd5          ethtool         fsck.msdos    ifquery        iptables-save      killall5          mkfs.ext3    mount.cifs        ntfsundelete   reboot       runuser       swapon             wipefs
    capsh          dmsetup          fake-hwclock    fsck.vfat     ifup           iptunnel           ldconfig          mkfs.ext4    mount.fuse        osd_login      regdbdump    setcap        switch_root        wpa_action
    cfdisk         dmstats          fatlabel        fsfreeze      init           isosize            logsave           mkfs.fat     mount.lowntfs-3g  pam_tally      request-key  sfdisk        sysctl             wpa_cli
    chcpu          dosfsck          fdisk           fstab-decode  insmod         iw                 losetup           mkfs.minix   mount.nfs         pam_tally2     resize2fs    shadowconfig  tc                 wpa_supplicant
    crda           dosfslabel       findfs          fstrim        installkernel  iwconfig           lsmod             mkfs.msdos   mount.nfs4        parted         resolvconf   showmount     telinit            zramctl

    srv:

    sys:
    block  bus  class  dev  devices  firmware  fs  hypervisor  kernel  module  power

    tmp:

    usr:
    bin  games  include  lib  local  sbin  share  src

    var:
    backups  cache  lib  local  lock  log  mail  opt  run  spool  tmp

## 通常盤との差分(パッケージ)

Lite 版にはなく, 通常版にはインストールされているパッケージのリストが以下である。
減分はなかったので省略する。

なお通常版 Lite 版それぞれ, docker image 内で`dpkg --get-selections | grep -v deinstall`を実行した結果を`pkg.txt` と `lite_pkg.txt`に保存し差分を評価した。

    $ diff -u {lite_,}pkg.txt | grep  -e ^+ | grep -v ^++
    +adwaita-icon-theme                              install
    +alacarte                                        install
    +arandr                                          install
    +aspell                                          install
    +aspell-en                                       install
    +blt                                             install
    +bluealsa                                        install
    +bubblewrap                                      install
    +chromium-browser                                install
    +chromium-browser-l10n                           install
    +chromium-codecs-ffmpeg-extra                    install
    +dbus-user-session                               install
    +dbus-x11                                        install
    +dconf-gsettings-backend:armhf                   install
    +dconf-service                                   install
    +debian-reference-common                         install
    +debian-reference-en                             install
    +desktop-base                                    install
    +desktop-file-utils                              install
    +dh-python                                       install
    +dictionaries-common                             install
    +dillo                                           install
    +docutils-common                                 install
    +eject                                           install
    +emacsen-common                                  install
    +ffmpeg                                          install
    +fontconfig                                      install
    +fontconfig-config                               install
    +fonts-dejavu-core                               install
    +fonts-droid-fallback                            install
    +fonts-freefont-ttf                              install
    +fonts-liberation2                               install
    +fonts-noto-mono                                 install
    +fonts-piboto                                    install
    +fonts-quicksand                                 install
    +galculator                                      install
    +gdisk                                           install
    +geany                                           install
    +geany-common                                    install
    +giblib1:armhf                                   install
    +gir1.2-atk-1.0:armhf                            install
    +gir1.2-freedesktop:armhf                        install
    +gir1.2-gdkpixbuf-2.0:armhf                      install
    +gir1.2-glib-2.0:armhf                           install
    +gir1.2-gmenu-3.0:armhf                          install
    +gir1.2-gtk-3.0:armhf                            install
    +gir1.2-pango-1.0:armhf                          install
    +git                                             install
    +git-man                                         install
    +gldriver-test                                   install
    +glib-networking:armhf                           install
    +glib-networking-common                          install
    +glib-networking-services                        install
    +gnome-accessibility-themes                      install
    +gnome-icon-theme                                install
    +gnome-menus                                     install
    +gnome-themes-extra:armhf                        install
    +gnome-themes-extra-data                         install
    +gnome-themes-standard                           install
    +gpicview                                        install
    +gsettings-desktop-schemas                       install
    +gstreamer1.0-alsa:armhf                         install
    +gstreamer1.0-libav:armhf                        install
    +gstreamer1.0-omx                                install
    +gstreamer1.0-omx-rpi                            install
    +gstreamer1.0-omx-rpi-config                     install
    +gstreamer1.0-plugins-bad:armhf                  install
    +gstreamer1.0-plugins-base:armhf                 install
    +gstreamer1.0-plugins-good:armhf                 install
    +gstreamer1.0-x:armhf                            install
    +gtk-update-icon-cache                           install
    +gtk2-engines:armhf                              install
    +gtk2-engines-clearlookspix:armhf                install
    +gtk2-engines-pixbuf:armhf                       install
    +gtk2-engines-pixflat:armhf                      install
    +gvfs:armhf                                      install
    +gvfs-backends                                   install
    +gvfs-common                                     install
    +gvfs-daemons                                    install
    +gvfs-fuse                                       install
    +gvfs-libs:armhf                                 install
    +hicolor-icon-theme                              install
    +hunspell-en-gb                                  install
    +hyphen-en-gb                                    install
    +i2c-tools                                       install
    +javascript-common                               install
    +laptop-detect                                   install
    +liba52-0.7.4:armhf                              install
    +libaa1:armhf                                    install
    +libaom0:armhf                                   install
    +libappstream4:armhf                             install
    +libarchive13:armhf                              install
    +libaribb24-0:armhf                              install
    +libaspell15:armhf                               install
    +libass9:armhf                                   install
    +libasyncns0:armhf                               install
    +libatasmart4:armhf                              install
    +libatk-bridge2.0-0:armhf                        install
    +libatk1.0-0:armhf                               install
    +libatk1.0-data                                  install
    +libatspi2.0-0:armhf                             install
    +libavahi-client3:armhf                          install
    +libavahi-glib1:armhf                            install
    +libavc1394-0:armhf                              install
    +libavcodec58:armhf                              install
    +libavdevice58:armhf                             install
    +libavfilter7:armhf                              install
    +libavformat58:armhf                             install
    +libavresample4:armhf                            install
    +libavutil56:armhf                               install
    +libbasicusageenvironment1:armhf                 install
    +libblas3:armhf                                  install
    +libblockdev-fs2:armhf                           install
    +libblockdev-loop2:armhf                         install
    +libblockdev-part-err2:armhf                     install
    +libblockdev-part2:armhf                         install
    +libblockdev-swap2:armhf                         install
    +libblockdev-utils2:armhf                        install
    +libblockdev2:armhf                              install
    +libbluetooth3:armhf                             install
    +libbluray2:armhf                                install
    +libbrotli1:armhf                                install
    +libbs2b0:armhf                                  install
    +libcaca0:armhf                                  install
    +libcairo-gobject2:armhf                         install
    +libcairo2:armhf                                 install
    +libcanberra-gtk3-0:armhf                        install
    +libcanberra0:armhf                              install
    +libcddb2                                        install
    +libcdio-cdda2:armhf                             install
    +libcdio-paranoia2:armhf                         install
    +libcdio18:armhf                                 install
    +libcdparanoia0:armhf                            install
    +libchromaprint1:armhf                           install
    +libcodec2-0.8.1:armhf                           install
    +libcolord2:armhf                                install
    +libcroco3:armhf                                 install
    +libcups2:armhf                                  install
    +libcupsfilters1:armhf                           install
    +libcupsimage2:armhf                             install
    +libcurl3-gnutls:armhf                           install
    +libdatrie1:armhf                                install
    +libdav1d3:armhf                                 install
    +libdbus-glib-1-2:armhf                          install
    +libdc1394-22:armhf                              install
    +libdca0:armhf                                   install
    +libdconf1:armhf                                 install
    +libde265-0:armhf                                install
    +libdjvulibre-text                               install
    +libdjvulibre21:armhf                            install
    +libdouble-conversion1:armhf                     install
    +libdrm-amdgpu1:armhf                            install
    +libdrm-common                                   install
    +libdrm-nouveau2:armhf                           install
    +libdrm-radeon1:armhf                            install
    +libdrm2:armhf                                   install
    +libdv4:armhf                                    install
    +libdvbpsi10:armhf                               install
    +libdvdnav4:armhf                                install
    +libdvdread4:armhf                               install
    +libebml4v5:armhf                                install
    +libegl-mesa0:armhf                              install
    +libegl1:armhf                                   install
    +libenchant1c2a:armhf                            install
    +libepoxy0:armhf                                 install
    +liberror-perl                                   install
    +libevdev2:armhf                                 install
    +libexif12:armhf                                 install
    +libexpat1-dev:armhf                             install
    +libfaad2:armhf                                  install
    +libfftw3-double3:armhf                          install
    +libflac8:armhf                                  install
    +libflite1:armhf                                 install
    +libfltk1.3:armhf                                install
    +libfluidsynth1:armhf                            install
    +libfm-data                                      install
    +libfm-extra4:armhf                              install
    +libfm-gtk-data                                  install
    +libfm-gtk4:armhf                                install
    +libfm-modules:armhf                             install
    +libfm4:armhf                                    install
    +libfontconfig1:armhf                            install
    +libfontenc1:armhf                               install
    +libgbm1:armhf                                   install
    +libgck-1-0:armhf                                install
    +libgcr-base-3-1:armhf                           install
    +libgd3:armhf                                    install
    +libgdata-common                                 install
    +libgdata22:armhf                                install
    +libgdk-pixbuf2.0-0:armhf                        install
    +libgdk-pixbuf2.0-common                         install
    +libgfortran5:armhf                              install
    +libgif7:armhf                                   install
    +libgirepository-1.0-1:armhf                     install
    +libgl1:armhf                                    install
    +libgl1-mesa-dri:armhf                           install
    +libglapi-mesa:armhf                             install
    +libgles1:armhf                                  install
    +libgles2:armhf                                  install
    +libgles2-mesa:armhf                             install
    +libglib2.0-bin                                  install
    +libglvnd0:armhf                                 install
    +libglx-mesa0:armhf                              install
    +libglx0:armhf                                   install
    +libgme0:armhf                                   install
    +libgnome-menu-3-0:armhf                         install
    +libgoa-1.0-0b:armhf                             install
    +libgoa-1.0-common                               install
    +libgphoto2-6:armhf                              install
    +libgphoto2-port12:armhf                         install
    +libgraphite2-3:armhf                            install
    +libgroupsock8:armhf                             install
    +libgs9:armhf                                    install
    +libgs9-common                                   install
    +libgsm1:armhf                                   install
    +libgssdp-1.0-3:armhf                            install
    +libgstreamer-gl1.0-0:armhf                      install
    +libgstreamer-plugins-bad1.0-0:armhf             install
    +libgstreamer-plugins-base1.0-0:armhf            install
    +libgstreamer1.0-0:armhf                         install
    +libgtk-3-0:armhf                                install
    +libgtk-3-common                                 install
    +libgtk2.0-0:armhf                               install
    +libgtk2.0-bin                                   install
    +libgtk2.0-common                                install
    +libgtksourceview-3.0-1:armhf                    install
    +libgtksourceview-3.0-common                     install
    +libgudev-1.0-0:armhf                            install
    +libgupnp-1.0-4:armhf                            install
    +libgupnp-igd-1.0-4:armhf                        install
    +libharfbuzz-icu0:armhf                          install
    +libharfbuzz0b:armhf                             install
    +libhunspell-1.7-0:armhf                         install
    +libhyphen0:armhf                                install
    +libi2c0:armhf                                   install
    +libice6:armhf                                   install
    +libid3tag0:armhf                                install
    +libiec61883-0:armhf                             install
    +libijs-0.35:armhf                               install
    +libilmbase23:armhf                              install
    +libimagequant0:armhf                            install
    +libimlib2:armhf                                 install
    +libimobiledevice6:armhf                         install
    +libindicator3-7:armhf                           install
    +libinput-bin                                    install
    +libinput10:armhf                                install
    +libixml10:armhf                                 install
    +libjack-jackd2-0:armhf                          install
    +libjansson4:armhf                               install
    +libjavascriptcoregtk-4.0-18:armhf               install
    +libjbig0:armhf                                  install
    +libjbig2dec0:armhf                              install
    +libjs-jquery                                    install
    +libjs-sphinxdoc                                 install
    +libjs-underscore                                install
    +libjson-glib-1.0-0:armhf                        install
    +libjson-glib-1.0-common                         install
    +libkate1:armhf                                  install
    +libkeybinder0                                   install
    +liblapack3:armhf                                install
    +liblcms2-2:armhf                                install
    +libldb1:armhf                                   install
    +liblightdm-gobject-1-0:armhf                    install
    +liblilv-0-0:armhf                               install
    +liblirc-client0:armhf                           install
    +liblivemedia64:armhf                            install
    +libllvm9:armhf                                  install
    +libltdl7:armhf                                  install
    +liblua5.2-0:armhf                               install
    +libmad0:armhf                                   install
    +libmatroska6v5:armhf                            install
    +libmenu-cache-bin                               install
    +libmenu-cache3:armhf                            install
    +libmicrodns0:armhf                              install
    +libmikmod3:armhf                                install
    +libmjpegutils-2.1-0                             install
    +libmms0:armhf                                   install
    +libmodplug1:armhf                               install
    +libmp3lame0:armhf                               install
    +libmpcdec6:armhf                                install
    +libmpeg2-4:armhf                                install
    +libmpeg2encpp-2.1-0                             install
    +libmpg123-0:armhf                               install
    +libmplex2-2.1-0                                 install
    +libmtdev1:armhf                                 install
    +libmysofa0:armhf                                install
    +libnfs12:armhf                                  install
    +libnice10:armhf                                 install
    +libnorm1:armhf                                  install
    +libnotify4:armhf                                install
    +libnspr4:armhf                                  install
    +libnss3:armhf                                   install
    +liboauth0:armhf                                 install
    +libobrender32v5                                 install
    +libobt2v5                                       install
    +libofa0:armhf                                   install
    +libogg0:armhf                                   install
    +libopenal-data                                  install
    +libopenal1:armhf                                install
    +libopenexr23:armhf                              install
    +libopenjp2-7:armhf                              install
    +libopenmpt-modplug1:armhf                       install
    +libopenmpt0:armhf                               install
    +libopus0:armhf                                  install
    +liborc-0.4-0:armhf                              install
    +libossp-uuid16:armhf                            install
    +libpackagekit-glib2-18:armhf                    install
    +libpango-1.0-0:armhf                            install
    +libpangocairo-1.0-0:armhf                       install
    +libpangoft2-1.0-0:armhf                         install
    +libpangoxft-1.0-0:armhf                         install
    +libpaper-utils                                  install
    +libpaper1:armhf                                 install
    +libparted-fs-resize0:armhf                      install
    +libpciaccess0:armhf                             install
    +libpcre2-16-0:armhf                             install
    +libpgm-5.2-0:armhf                              install
    +libpigpio-dev                                   install
    +libpigpio1                                      install
    +libpigpiod-if-dev                               install
    +libpigpiod-if1                                  install
    +libpigpiod-if2-1                                install
    +libpixman-1-0:armhf                             install
    +libplacebo7:armhf                               install
    +libplist3:armhf                                 install
    +libplymouth4:armhf                              install
    +libpoppler-qt5-1:armhf                          install
    +libpoppler82:armhf                              install
    +libportmidi0:armhf                              install
    +libpostproc55:armhf                             install
    +libprotobuf-lite17:armhf                        install
    +libproxy-tools                                  install
    +libproxy1v5:armhf                               install
    +libpulse0:armhf                                 install
    +libpython-all-dev:armhf                         install
    +libpython-dev:armhf                             install
    +libpython2-dev:armhf                            install
    +libpython2.7:armhf                              install
    +libpython2.7-dev:armhf                          install
    +libpython3-dev:armhf                            install
    +libpython3.7-dev:armhf                          install
    +libqt5concurrent5:armhf                         install
    +libqt5core5a:armhf                              install
    +libqt5dbus5:armhf                               install
    +libqt5gui5:armhf                                install
    +libqt5network5:armhf                            install
    +libqt5printsupport5:armhf                       install
    +libqt5sql5:armhf                                install
    +libqt5sql5-sqlite:armhf                         install
    +libqt5svg5:armhf                                install
    +libqt5widgets5:armhf                            install
    +libqt5x11extras5:armhf                          install
    +libqt5xml5:armhf                                install
    +libraw1394-11:armhf                             install
    +libresid-builder0c2a                            install
    +librest-0.7-0:armhf                             install
    +librsvg2-2:armhf                                install
    +librsvg2-common:armhf                           install
    +librtimulib-dev                                 install
    +librtimulib-utils                               install
    +librtimulib7                                    install
    +librubberband2:armhf                            install
    +libsbc1:armhf                                   install
    +libsdl-image1.2:armhf                           install
    +libsdl-mixer1.2:armhf                           install
    +libsdl-ttf2.0-0:armhf                           install
    +libsdl1.2debian:armhf                           install
    +libsdl2-2.0-0:armhf                             install
    +libsecret-1-0:armhf                             install
    +libsecret-common                                install
    +libsensors-config                               install
    +libsensors5:armhf                               install
    +libserd-0-0:armhf                               install
    +libshine3:armhf                                 install
    +libshout3:armhf                                 install
    +libsidplay2                                     install
    +libsm6:armhf                                    install
    +libsmbclient:armhf                              install
    +libsnappy1v5:armhf                              install
    +libsndfile1:armhf                               install
    +libsndio7.0:armhf                               install
    +libsodium23:armhf                               install
    +libsord-0-0:armhf                               install
    +libsoundtouch1:armhf                            install
    +libsoup-gnome2.4-1:armhf                        install
    +libsoup2.4-1:armhf                              install
    +libsoxr0:armhf                                  install
    +libspandsp2:armhf                               install
    +libspatialaudio0:armhf                          install
    +libspectre1:armhf                               install
    +libspeex1:armhf                                 install
    +libspeexdsp1:armhf                              install
    +libsratom-0-0:armhf                             install
    +libsrtp2-1:armhf                                install
    +libssh-gcrypt-4:armhf                           install
    +libstartup-notification0:armhf                  install
    +libstemmer0d:armhf                              install
    +libswresample3:armhf                            install
    +libswscale5:armhf                               install
    +libsynctex2:armhf                               install
    +libtag1v5:armhf                                 install
    +libtag1v5-vanilla:armhf                         install
    +libtcl8.6:armhf                                 install
    +libtdb1:armhf                                   install
    +libtevent0:armhf                                install
    +libthai-data                                    install
    +libthai0:armhf                                  install
    +libtheora0:armhf                                install
    +libtiff5:armhf                                  install
    +libtk8.6:armhf                                  install
    +libtwolame0:armhf                               install
    +libudisks2-0:armhf                              install
    +libunique-1.0-0                                 install
    +libunwind8:armhf                                install
    +libupnp13:armhf                                 install
    +libusageenvironment3:armhf                      install
    +libusbmuxd4:armhf                               install
    +libva-drm2:armhf                                install
    +libva-x11-2:armhf                               install
    +libva2:armhf                                    install
    +libvdpau-va-gl1:armhf                           install
    +libvdpau1:armhf                                 install
    +libvidstab1.1:armhf                             install
    +libvisual-0.4-0:armhf                           install
    +libvlc-bin:armhf                                install
    +libvlc5:armhf                                   install
    +libvlccore9:armhf                               install
    +libvo-aacenc0:armhf                             install
    +libvo-amrwbenc0:armhf                           install
    +libvorbis0a:armhf                               install
    +libvorbisenc2:armhf                             install
    +libvorbisfile3:armhf                            install
    +libvpx5:armhf                                   install
    +libvte-2.91-0:armhf                             install
    +libvte-2.91-common                              install
    +libvulkan1:armhf                                install
    +libwacom-common                                 install
    +libwacom2:armhf                                 install
    +libwavpack1:armhf                               install
    +libwayland-client0:armhf                        install
    +libwayland-cursor0:armhf                        install
    +libwayland-egl1:armhf                           install
    +libwayland-server0:armhf                        install
    +libwebkit2gtk-4.0-37:armhf                      install
    +libwebp6:armhf                                  install
    +libwebpdemux2:armhf                             install
    +libwebpmux3:armhf                               install
    +libwebrtc-audio-processing1:armhf               install
    +libwildmidi2:armhf                              install
    +libwnck-common                                  install
    +libwnck22:armhf                                 install
    +libwoff1:armhf                                  install
    +libx11-xcb1:armhf                               install
    +libx264-155:armhf                               install
    +libx265-165:armhf                               install
    +libxaw7:armhf                                   install
    +libxcb-dri2-0:armhf                             install
    +libxcb-dri3-0:armhf                             install
    +libxcb-glx0:armhf                               install
    +libxcb-icccm4:armhf                             install
    +libxcb-image0:armhf                             install
    +libxcb-keysyms1:armhf                           install
    +libxcb-present0:armhf                           install
    +libxcb-randr0:armhf                             install
    +libxcb-render-util0:armhf                       install
    +libxcb-render0:armhf                            install
    +libxcb-shape0:armhf                             install
    +libxcb-shm0:armhf                               install
    +libxcb-sync1:armhf                              install
    +libxcb-util0:armhf                              install
    +libxcb-xfixes0:armhf                            install
    +libxcb-xinerama0:armhf                          install
    +libxcb-xkb1:armhf                               install
    +libxcb-xv0:armhf                                install
    +libxcomposite1:armhf                            install
    +libxcursor1:armhf                               install
    +libxdamage1:armhf                               install
    +libxfixes3:armhf                                install
    +libxfont2:armhf                                 install
    +libxft2:armhf                                   install
    +libxi6:armhf                                    install
    +libxinerama1:armhf                              install
    +libxkbcommon-x11-0:armhf                        install
    +libxkbcommon0:armhf                             install
    +libxkbfile1:armhf                               install
    +libxklavier16:armhf                             install
    +libxmu6:armhf                                   install
    +libxpm4:armhf                                   install
    +libxrandr2:armhf                                install
    +libxrender1:armhf                               install
    +libxres1:armhf                                  install
    +libxshmfence1:armhf                             install
    +libxslt1.1:armhf                                install
    +libxss1:armhf                                   install
    +libxt6:armhf                                    install
    +libxtst6:armhf                                  install
    +libxv1:armhf                                    install
    +libxvidcore4:armhf                              install
    +libxxf86dga1:armhf                              install
    +libxxf86vm1:armhf                               install
    +libyaml-0-2:armhf                               install
    +libzbar0:armhf                                  install
    +libzmq5:armhf                                   install
    +libzvbi-common                                  install
    +libzvbi0:armhf                                  install
    +lightdm                                         install
    +lightdm-gtk-greeter                             install
    +lsof                                            install
    +lxappearance                                    install
    +lxappearance-obconf                             install
    +lxde                                            install
    +lxde-common                                     install
    +lxde-core                                       install
    +lxde-icon-theme                                 install
    +lxhotkey-core                                   install
    +lxhotkey-gtk                                    install
    +lxinput                                         install
    +lxmenu-data                                     install
    +lxpanel                                         install
    +lxpanel-data                                    install
    +lxplug-bluetooth                                install
    +lxplug-cputemp                                  install
    +lxplug-ejecter                                  install
    +lxplug-network                                  install
    +lxplug-ptbatt                                   install
    +lxplug-volume                                   install
    +lxpolkit                                        install
    +lxrandr                                         install
    +lxsession                                       install
    +lxsession-data                                  install
    +lxsession-edit                                  install
    +lxsession-logout                                install
    +lxtask                                          install
    +lxterminal                                      install
    +menu-xdg                                        install
    +mesa-va-drivers:armhf                           install
    +mesa-vdpau-drivers:armhf                        install
    +mousepad                                        install
    +mypy                                            install
    +obconf                                          install
    +omxplayer                                       install
    +openbox                                         install
    +openbox-lxde-session                            install
    +packagekit                                      install
    +pcmanfm                                         install
    +pi-greeter                                      install
    +pi-language-support                             install
    +pi-package                                      install
    +pi-package-data                                 install
    +pi-package-session                              install
    +piclone                                         install
    +pigpio                                          install
    +pigpio-tools                                    install
    +pigpiod                                         install
    +pipanel                                         install
    +pishutdown                                      install
    +piwiz                                           install
    +pixflat-icons                                   install
    +plymouth                                        install
    +plymouth-label                                  install
    +plymouth-themes                                 install
    +poppler-data                                    install
    +pprompt                                         install
    +pylint3                                         install
    +pypy                                            install
    +pypy-lib:armhf                                  install
    +python-all                                      install
    +python-all-dev                                  install
    +python-asn1crypto                               install
    +python-automationhat                            install
    +python-blinker                                  install
    +python-blinkt                                   install
    +python-buttonshim                               install
    +python-cairo:armhf                              install
    +python-cap1xxx                                  install
    +python-certifi                                  install
    +python-cffi-backend                             install
    +python-chardet                                  install
    +python-click                                    install
    +python-colorama                                 install
    +python-colorzero                                install
    +python-configparser                             install
    +python-cookies                                  install
    +python-crypto                                   install
    +python-cryptography                             install
    +python-dbus                                     install
    +python-dev                                      install
    +python-drumhat                                  install
    +python-entrypoints                              install
    +python-enum34                                   install
    +python-envirophat                               install
    +python-explorerhat                              install
    +python-flask                                    install
    +python-fourletterphat                           install
    +python-funcsigs                                 install
    +python-gi                                       install
    +python-gobject-2                                install
    +python-gpiozero                                 install
    +python-gtk2                                     install
    +python-idna                                     install
    +python-ipaddress                                install
    +python-itsdangerous                             install
    +python-jinja2                                   install
    +python-jwt                                      install
    +python-keyring                                  install
    +python-keyrings.alt                             install
    +python-markupsafe                               install
    +python-microdotphat                             install
    +python-mock                                     install
    +python-mote                                     install
    +python-motephat                                 install
    +python-numpy                                    install
    +python-oauthlib                                 install
    +python-olefile                                  install
    +python-openssl                                  install
    +python-pantilthat                               install
    +python-pbr                                      install
    +python-phatbeat                                 install
    +python-pianohat                                 install
    +python-picamera                                 install
    +python-piglow                                   install
    +python-pigpio                                   install
    +python-pil:armhf                                install
    +python-pip                                      install
    +python-pip-whl                                  install
    +python-pkg-resources                            install
    +python-pygame                                   install
    +python-pyinotify                                install
    +python-rainbowhat                               install
    +python-requests                                 install
    +python-requests-oauthlib                        install
    +python-responses                                install
    +python-rtimulib                                 install
    +python-scrollphat                               install
    +python-scrollphathd                             install
    +python-secretstorage                            install
    +python-sense-hat                                install
    +python-serial                                   install
    +python-setuptools                               install
    +python-simplejson                               install
    +python-six                                      install
    +python-skywriter                                install
    +python-smbus:armhf                              install
    +python-sn3218                                   install
    +python-spidev                                   install
    +python-talloc:armhf                             install
    +python-tk                                       install
    +python-touchphat                                install
    +python-twython                                  install
    +python-unicornhathd                             install
    +python-urllib3                                  install
    +python-werkzeug                                 install
    +python-wheel                                    install
    +python-xdg                                      install
    +python2-dev                                     install
    +python2.7-dev                                   install
    +python3-asn1crypto                              install
    +python3-astroid                                 install
    +python3-asttokens                               install
    +python3-automationhat                           install
    +python3-blinker                                 install
    +python3-blinkt                                  install
    +python3-bs4                                     install
    +python3-buttonshim                              install
    +python3-cap1xxx                                 install
    +python3-cffi-backend                            install
    +python3-click                                   install
    +python3-colorama                                install
    +python3-colorzero                               install
    +python3-cookies                                 install
    +python3-crypto                                  install
    +python3-cryptography                            install
    +python3-dbus                                    install
    +python3-dev                                     install
    +python3-distutils                               install
    +python3-docutils                                install
    +python3-drumhat                                 install
    +python3-entrypoints                             install
    +python3-envirophat                              install
    +python3-explorerhat                             install
    +python3-flask                                   install
    +python3-fourletterphat                          install
    +python3-gi                                      install
    +python3-gpiozero                                install
    +python3-html5lib                                install
    +python3-isort                                   install
    +python3-itsdangerous                            install
    +python3-jedi                                    install
    +python3-jinja2                                  install
    +python3-jwt                                     install
    +python3-keyring                                 install
    +python3-keyrings.alt                            install
    +python3-lazy-object-proxy                       install
    +python3-lib2to3                                 install
    +python3-logilab-common                          install
    +python3-lxml:armhf                              install
    +python3-markupsafe                              install
    +python3-mccabe                                  install
    +python3-microdotphat                            install
    +python3-mote                                    install
    +python3-motephat                                install
    +python3-mypy                                    install
    +python3-mypy-extensions                         install
    +python3-numpy                                   install
    +python3-oauthlib                                install
    +python3-olefile                                 install
    +python3-openssl                                 install
    +python3-pantilthat                              install
    +python3-parso                                   install
    +python3-pgzero                                  install
    +python3-phatbeat                                install
    +python3-pianohat                                install
    +python3-picamera                                install
    +python3-piglow                                  install
    +python3-pigpio                                  install
    +python3-pil:armhf                               install
    +python3-pip                                     install
    +python3-psutil                                  install
    +python3-pygame                                  install
    +python3-pygments                                install
    +python3-pyinotify                               install
    +python3-rainbowhat                              install
    +python3-requests-oauthlib                       install
    +python3-responses                               install
    +python3-roman                                   install
    +python3-rpi.gpio                                install
    +python3-rtimulib                                install
    +python3-scrollphat                              install
    +python3-scrollphathd                            install
    +python3-secretstorage                           install
    +python3-send2trash                              install
    +python3-sense-hat                               install
    +python3-serial                                  install
    +python3-setuptools                              install
    +python3-simplejson                              install
    +python3-skywriter                               install
    +python3-smbus:armhf                             install
    +python3-sn3218                                  install
    +python3-soupsieve                               install
    +python3-spidev                                  install
    +python3-tk:armhf                                install
    +python3-touchphat                               install
    +python3-twython                                 install
    +python3-typed-ast                               install
    +python3-unicornhathd                            install
    +python3-venv                                    install
    +python3-webencodings                            install
    +python3-werkzeug                                install
    +python3-wheel                                   install
    +python3-wrapt                                   install
    +python3-xdg                                     install
    +python3.7-dev                                   install
    +python3.7-venv                                  install
    +qpdfview                                        install
    +qpdfview-djvu-plugin                            install
    +qpdfview-ps-plugin                              install
    +qpdfview-translations                           install
    +qt5-gtk-platformtheme:armhf                     install
    +qt5-style-plugins:armhf                         install
    +qt5ct                                           install
    +qttranslations5-l10n                            install
    +raspberrypi-artwork                             install
    +raspberrypi-ui-mods                             install
    +raspi-gpio                                      install
    +rc-gui                                          install
    +read-edid                                       install
    +realvnc-vnc-server                              install
    +rp-prefapps                                     install
    +rpd-plym-splash                                 install
    +rpd-wallpaper                                   install
    +rpi-chromium-mods                               install
    +samba-libs:armhf                                install
    +scrot                                           install
    +sense-hat                                       install
    +sgml-base                                       install
    +sound-theme-freedesktop                         install
    +thonny                                          install
    +timgm6mb-soundfont                              install
    +tk8.6-blt2.5                                    install
    +tree                                            install
    +udisks2                                         install
    +uuid                                            install
    +va-driver-all:armhf                             install
    +vdpau-driver-all:armhf                          install
    +vlc                                             install
    +vlc-bin                                         install
    +vlc-data                                        install
    +vlc-l10n                                        install
    +vlc-plugin-base:armhf                           install
    +vlc-plugin-notify:armhf                         install
    +vlc-plugin-qt:armhf                             install
    +vlc-plugin-samba:armhf                          install
    +vlc-plugin-skins2:armhf                         install
    +vlc-plugin-video-output:armhf                   install
    +vlc-plugin-video-splitter:armhf                 install
    +vlc-plugin-visualization:armhf                  install
    +wamerican                                       install
    +wbritish                                        install
    +wiringpi                                        install
    +x11-common                                      install
    +x11-utils                                       install
    +x11-xkb-utils                                   install
    +x11-xserver-utils                               install
    +xarchiver                                       install
    +xcompmgr                                        install
    +xdg-dbus-proxy                                  install
    +xdg-utils                                       install
    +xinit                                           install
    +xinput                                          install
    +xml-core                                        install
    +xsel                                            install
    +xserver-common                                  install
    +xserver-xorg                                    install
    +xserver-xorg-core                               install
    +xserver-xorg-input-all                          install
    +xserver-xorg-input-libinput                     install
    +xserver-xorg-video-fbdev                        install
    +xserver-xorg-video-fbturbo                      install
    +zenity                                          install
    +zenity-common                                   install
