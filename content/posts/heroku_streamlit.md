---
title: "streamlit で画像処理アプリを作る。"
date: 2020-06-11T08:29:53+09:00
draft: false
toc: true
images:
tags:
  - python
  - heroku
---

最近流行の`streamlit`を使って簡単な画像処理アプリを作ったので備忘録

[デモページ](https://still-sands-82310.herokuapp.com/)

[ソースページ (Github)](https://github.com/tomowarkar/stapp)

{{< image src="/imgs/heroku_streamlit/01.gif" alt="アプリデモ" position="center" style="border-radius: 8px;" >}}

パッケージ管理には`pipenv`を使用。

## 顔検出モデル

[opencv/data/haarcascades at master · opencv/opencv](https://github.com/opencv/opencv/tree/master/data/haarcascades)

かなり昔に書いたのコードを流用した。

## streamlit どうやって Heroku にデプロイするの?

`Procfile`に以下のように記載。

```Procfile
web: streamlit run --server.enableCORS false --server.port $PORT app.py
```

[Hosting streamlit on Heroku - Questions - Streamlit](https://discuss.streamlit.io/t/hosting-streamlit-on-heroku/132/12)

より詳細は以下記事参照。

[Streamlit を Heroku にデプロイする。](https://qiita.com/tomowarkar/items/f41f778b6ae003d9a027)

## Python ファイル分割しないの?

streamlit の面白いところは以下のように`clone`とかなしに直接ローカル環境で試すことができる点だと思う。

```bash
$ streamlit run https://github.com/tomowarkar/stapp/blob/master/app.py
```

これをするにあたってできるだけシングルページにまとめた方がいいかな(分けるにしてもそのあたりを考えつつ)という意図。

## Heroku で OpenCV が使えない

何も知らずに Heroku で OpenCV をつかおうとすると以下のエラーが...

```
...
import cv2
from .cv2 import *
...
ImportError: libSM.so.6: cannot open shared object file: No such file or directory
```

### Heroku のビルドパックに heroku-buildpack-apt を追加

[heroku/heroku-buildpack-apt](https://github.com/heroku/heroku-buildpack-apt)

```bash
$ heroku buildpacks:add --index 1 https://github.com/heroku/heroku-buildpack-apt
```

### Aptfile を追加し、OpenCV の依存関係を入れる

`Aptfile`を作成し、 `libsm6`, `libxrender1`, `libfontconfig1`, `libice6` の 4 つのライブラリを 1 行毎に記載

```
libsm6
libxrender1
libfontconfig1
libice6
```

[python - How to use OpenCV with Heroku - Stack Overflow](https://stackoverflow.com/questions/49469764/how-to-use-opencv-with-heroku)

[heroku で OpenCV を利用する [Python3] - Qiita](https://qiita.com/haru1843/items/210cb08024195b9d1bc8)

## Heroku の無料枠を最大限使いたい

[Free Dyno Hours | Heroku Dev Center](https://devcenter.heroku.com/articles/free-dyno-hours)

Heroku のアプリはアクセスや内部実行がなければ 30 分間でスリープ状態に入り、スリープからの起動には少し時間がかかる。

無料枠を超えない範囲でアプリをスリープさせないようにトラフィックを送ってやればいい。

定期実行できればなんでもいいが、コードと一緒に管理できる`GitHub Actions`が個人的に扱いやすいのでこれで行う。

[GitHub Actions について - GitHub ヘルプ](https://help.github.com/ja/actions/getting-started-with-github-actions/about-github-actions#usage-limits)

### GitHub Actions で 20 分毎にアプリにトラフィックを送る

`Procfile` と 同階層に`.github/workflows/heroku.yml`を作成する。

`heroku.yml`に以下のように記載。

```yml
name: Heroku Alarm Clock

on:
  schedule:
    - cron: "*/20 * * * *"

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Alarm
        run: curl YOUR_HEROKU_APP_URL
```

cron を 20 分おきに実行し、curl でアプリにアクセスするというだけの内容だ。これだとデフォルトの無料枠は超えてしまうので好きに変更されたし。

ちなみに Heroku の個人アカウントにはデフォルトで毎月 550 時間の無料枠が割り当てられていて(アカウントに紐づく全てのアプリの総起動時間と思われる。)、超過すると月の残りは強制スリープになるので注意。

## できなかったこと

クライアント側のパラメータに応じてその場で動画を生成し、表示すること。

`/tmp`に`filename`を作成しそれを元に`st.video(video)`で表示する。

```python
fourcc = cv2.VideoWriter_fourcc(*"avc1")
video = cv2.VideoWriter(filename, fourcc, fps, (width, height))

steps = fps * 10
for i in range(steps):
    img = np.random.randint(0, 256, (width, height, 3), np.uint8)
    video.write(img)

video.release()
```

[残骸](https://github.com/tomowarkar/stapp/commit/568772006e507bed222a7bdb02780a5995ebb5da)

ローカルでは動作したけど、`heroku`上でうまく`/tmp`ディレクトリにファイルを作れず動作しなかった。
