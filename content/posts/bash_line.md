---
title: "BashからLINE botにメッセージを送る"
date: 2020-04-28T00:49:59+09:00
draft: false
toc: false
images:
tags:
  - bash
  - line
  - api
---

Mac で LINE を開くのすら面倒くさい時用

- [LINE Messaging API](https://developers.line.biz/ja/services/messaging-api/)
- [send push message](https://developers.line.biz/ja/docs/messaging-api/sending-messages/#methods-of-sending-message)

#### line.sh

```bash
#!/bin/bash
# @(#) Send message to line bot.

TOKEN="your token"
TO="your userId on bot"

pushMsg() {
    curl -s -X POST https://api.line.me/v2/bot/message/push \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{
        \"to\": \"$TO\",
        \"messages\":[
            {
                \"type\":\"text\",
                \"text\":\"$1\"
            }
        ]
    }"
}

res=$(pushMsg "$1" | jq ".message")

if [ "$res" = "null" ]; then
    echo "done!"
else
    echo $res
fi
exit 0
```

### Usage

```bash
$ # 成功した場合
$ sh line.sh こんにちは
done!

$ # 不正なToを指定した場合(例)
$ sh line.sh こんにちは
"The property, 'to', in the request body is invalid (line: -, column: -)"
```
