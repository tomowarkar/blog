---
title: "imgurに画像をアップロードするBashスクリプト"
date: 2020-04-10T11:32:50+09:00
draft: false
toc: true
images:
tags:
  - imgur
  - api
  - bash
---

選ばれたのは[imgur](https://imgur.com/)でした.

このブログでの画像の管理をどうしようかと30秒程考えた結果、imgurで管理することにしました。

それに応じてimgurにブログ用の画像を簡単にアップロードするbashスクリプトを書いたので備忘録。

### なぜこのブログの画像管理にimgurを選んだか

imgurを選んだ理由はこんな感じ
- apiが使える
- 無料であある
- 投稿オプションが豊富(匿名、アルバム, タグなど)

デメリットとしては、
- 画像サイズ制限
- 使われない画像の自動削除

などがあるが、画像サイズ制限はそこまで画質を重視しないのと,アップロード時の通信料を考えて元々圧縮した画像をアップロードするつもりなのでOK

使われない画像の自動削除については正直どうなるか未知数なので、今後の運用を見て適宜考えていくこととする。とはいえそこまで画像を多用するつもりはないので最悪消えても大丈夫だろう。



## スクリプト本文
### 依存
[imgur api doc](https://apidocs.imgur.com/?version=latest)

```bash
$ ffmpeg -version
ffmpeg version 4.2.2

$ jq --version
jq-1.6

$ curl --version
curl 7.64.1
```
### imgur.sh
```bash
# !/bin/bash
# imgurの特定のアルバムに写真をアップロードする。
COMMAND=`basename $0`

if [ ! $# -eq 1 ];then
echo "Usage: $COMMAND img_path"
exit 1
fi

# 画像を横600pxになるようにリサイズ
tmp_img="resized_img.png"
ffmpeg -i "$1" -vf scale=600:-1 $tmp_img

ACCESS_TOKEN="your imgur api auth acess token"
ALBUM_HASH="your imgur album hash"

JSON_RESPONSE=$(curl --request POST --url https://api.imgur.com/3/image --header "authorization: Bearer ${ACCESS_TOKEN}" -F "image=@$tmp_img" -F "album=$ALBUM_HASH")

success=`echo $JSON_RESPONSE | jq ".success"`
if [ $success = "true" ];then
  echo
  url=`echo $JSON_RESPONSE | jq ".data.link"`
  echo $url
  # ショートコード扱いになるため{{_ としているが、_は不要。
  echo "{{_<image src=$url alt=\"blog top page\" position=\"center\">}}"

  # アップロードに成功したら元画像をゴミ箱に入れる
  mv "$1" "/Users/username/.Trash/"
fi

# 可否によらず削除
rm $tmp_img
exit 0

```

少し改変してあるが、大まかにこんな感じで実装。

相変わらず `jq` は便利である。

## 個人的ポイント
### アップロード前のリサイズ
```
ffmpeg -i "$1" -vf scale=600:-1 $tmp_img
```
私のMac(MacBook Pro, 13-inch, 2016)でフルサイズのスクリーンショットをすると 2880×1800 の画像が保存される518万画素の3K画質である。

流石にそんなに高画質な画像は必要ないのと、手軽さを考え横のスケールを600pxに圧縮してアップロードすることにした。

フルサイズのスクリーンショットだと 2880×1800 が 600×375になるので約1/23のサイズになる

### アウトプットをHugoのショートコードで出力
HugoにはMarkdownで使える便利なショートコードがある

[Hugo :: Shortcodes](https://gohugo.io/content-management/shortcodes/)

アウトプットの形をショートコードにすることで画像のリサイズ・アップロードから、ショートコードの生成までを一気に任せてしまうことにした。


### rm の仕様
この辺りの操作

```
  # アップロードに成功したら元画像をゴミ箱に入れる
  mv "$1" "/Users/username/.Trash/"
fi

# 可否によらず削除
rm $tmp_img
```

自動生成の $tmp_img は `rm` で、元画像は `mv` でゴミ箱へって感じで運用しているが、`rm` は基本的には不可逆削除って認識であってるのかな?

軽く調べた限り時間が経ってないのであれば復元手段もあるらしいけど...


### 参考
- https://newfivefour.com/unix-imgur-basic-upload.html
- https://apidocs.imgur.com/?version=latest
