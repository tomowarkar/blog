---
title: "Google Colab の個人的 Tips"
date: 2020-05-05T22:39:13+09:00
draft: false
toc: true
images:
tags:
  - google
  - colab
---

## Google Drive のマウント 1

GUI を操作して Google Drive をマウントする

1. 左側にある 🗂:file_folder: から
2. ドライブをマウント
3. アクセスを許可の確認 > GOOGLE ドライブに接続
4. カレントディレクトリ配下に`drive`ファイルが作成されマウント完了

{{<image src="https://i.imgur.com/RScyikA.png" alt="blog top page" position="center">}}

## Google Drive のマウント 2

```python
# mount google drive
from google.colab import drive
drive.mount('drive')
```

上記コードを実行すると以下のように認証のための URL と認証コード入力画面が出る

```
Go to this URL in a browser: path/to/auth

Enter your authorization code:

```

1. 認証 URL をクリック
2. アカウントの選択 > 許可
3. ログインコードをコピーしてコード入力画面に貼り付け, 実行
4. カレントディレクトリ配下に`drive`(もしくは任意の)ファイルが作成されマウント完了

## Google Colab の ディレクトリ変更

他のシェル実行コマンドと同じように `! cd path/to/dir` としてもディレクトリ変更がなされない。

```bash
% cd path/to/dir
```

`% cd /content/drive/My\ Drive` としておくと直接 drive のファイルを操作できる

## ローカルからのファイルアップロード

```python
from google.colab import files
uploaded = files.upload()
```

## ローカルへのファイルダウンロード

```python
from google.colab import files

files.download('path/to/file.txt')
```

## 画像の表示

```python
from IPython.display import Image
Image('path/to/image.png', width=200)
```

参考: [ローカル ファイル システム](https://colab.research.google.com/notebooks/io.ipynb)

## 個人的メモ

### util コマンド

```bash
# drive に直接アクセス
% cd /content/drive/My\ Drive

! grep 'hoge' -ilr . --include='*.py'

! find . -name *txt
```

### pip 系コマンド

```bash
# pip install
! pip install pkg

# pip の パッケージリストの取得
! pip list

# パッケージのバージョンとか詳細
! pip show pkg
```

### apt 系コマンド

```bash
# インストール
! apt-get install pkg

# dpkg系
! dpkg --help
! dpkg -L pkg

# パッケージの削除
! apt-get purge pkg
```

[[Ubuntu] apt-get まとめ](https://qiita.com/white_aspara25/items/723ae4ebf0bfefe2115c)

### MeCab インストール

```bash
# See: https://pypi.org/project/mecab-python3/
! apt-get install swig libmecab-dev mecab-ipadic-utf8
! pip install mecab-python3

# 必要に応じてdicdirやuserdicを書き換える
! find . -name mecabrc
! cat /etc/mecabrc
```

### 拾い画像

{{<image src="https://cdn.analyticsvidhya.com/wp-content/uploads/2020/03/ct14.png" alt="blog top page" position="center">}}

### ドライブにパッケージを保存したかったり(検証途中)

```bash
# ドライブ内にパッケージのダウンロード
! apt-get --download-only -o dir::cache=/content/drive/My\ Drive/src/apt install pkg
! pip download -d /content/drive/My\ Drive/src/pip --no-binary :all: pkg

# ドライブ内からのパッケージのインストール
! apt-get install /content/drive/My\ Drive/src/apt/archives/*.deb
! pip install /content/drive/My\ Drive/src/pip/*.tar.gz
```

#### パッケージインストールの永続化のベストアンサー募集

必須ってわけじゃないけど、重いパッケージを毎回インストールするのは面倒だよね

とは言いつつも全部をドライブ内で管理しようとしても依存関係とかめんどそうだしどうしようかなーっていう現状

- [How do I install a library permanently in Colab?](https://stackoverflow.com/questions/55253498/how-do-i-install-a-library-permanently-in-colab)
- [is there any way to not installing packages on Google Colab every time?](https://stackoverflow.com/questions/49308803/is-there-any-way-to-not-installing-packages-on-google-colab-every-time?rq=1)
- [pip install をオフラインで行う](https://qiita.com/saten/items/d2ac85947583723246bf)
- [オフラインの Ubuntu にパッケージインストール](https://dawtrav.skr.jp/blog/ubuntu/install-package-offline/)
