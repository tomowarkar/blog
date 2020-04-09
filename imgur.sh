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

# import $ALBUM_HASH, $ACCESS_TOKEN
source ./settings.sh

JSON_RESPONSE=$(curl --request POST --url https://api.imgur.com/3/image --header "authorization: Bearer ${ACCESS_TOKEN}" -F "image=@$tmp_img" -F "album=$ALBUM_HASH")

success=`echo $JSON_RESPONSE | jq ".success"`
if [ $success = "true" ];then
  echo
  echo "Account: https://tomowarkar.imgur.com/all/"
  echo "Album: https://imgur.com/a/$ALBUM_HASH"
  echo
  url=`echo $JSON_RESPONSE | jq ".data.link"`
  echo $url
  echo "{{<image src=$url alt=\"blog top page\" position=\"center\">}}"

  # アップロードに成功したら元画像をゴミ箱に入れる
  mv "$1" "/Users/tomowarkar/.Trash/"
fi

# 可否によらず削除
rm $tmp_img
exit 0
