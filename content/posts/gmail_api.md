---
title: "Gmail API 受信フォルダの内容確認"
date: 2020-04-28T00:01:07+09:00
draft: false
toc: false
images:
tags:
  - python
  - google
  - api
---

コロナウイルス拡大に伴い、普段使っている UQ モバイルで学生向け（25 歳以下）に UQ mobile データ容量 30GB まで無償提供が発表された。

[新型コロナウイルス感染症の影響拡大に伴う支援措置について](https://www.uqwimax.jp/annai/news_release/202004061.html)

説明をよく読んでみると

> このたび、新型コロナウィルス感染症の拡大による学校・教育機関等の休校措置を踏まえ、学生のオンライン授業の利用等を支援するため、2020 年 4 月 1 日から 2020 年 4 月 30 日まで、25 歳以下のお客さまを対象（注 2）に、UQ mobile サービス(スマートフォンサービス)において、月間データ容量超過後に追加した 30GB までのデータ容量を無償で提供します（注 3）。

> お客さまが「UQ mobile ポータルアプリ」または「データチャージサイト」より、追加でチャージしていただく必要がございます（注 5） 。データチャージによる追加購入手続き時の画面等には無償化対象となることが記載されませんが、本支援措置の適用条件を満たしたお客さまは、自動的に割引対象となります。

> （注 5）最大 30GB を無償でご利用いただくためには、「500MB 単位」でのご購入手続きが必要となります。

などとあり、かなりわかりづらく使いづらい仕様になっていることがわかる。最大 30GB 使うのには 60 回チャージしないとダメで、さらにそれが本当に割引されているかは引き落としまで分からないという恐怖である。やってるよっていう建前だけな気がしないでもない。

そもそも引き落としされるまで追加分が割引されるのかされないのか分からない仕様ってどうなんだろうか。ミスチャージによる課金を誘っている感が物すごい。（注 5）を読まずに 500MB 以上の単位で最大 30GB 分の追加チャージをすれば 30,000 円分の請求が来るのだろうか.そうなれば支援どころかコロナでお金を稼ぐ手段が限られる学生をより窮地に立たせることになる気がするのだが...

まあそれは置いておいて、この支援をより効率よく使いたいなということで Gmail API を使って自動化してしまおうという試み。

## 前提

- UQ モバイルではデータ通信量が制限に近づくと自動メールが送られる
- そのメールを元に UQ モバイルのデータチャージサイトへログイン, 500MB 分のチャージを行う

以上二つのサイクルを月間 60 回(30GB 分)の制限をつけて自動化

今回は Gmail API の部分のみ

## セットアップ

[https://developers.google.com/gmail/api/quickstart/python](https://developers.google.com/gmail/api/quickstart/python)

## main

```python
import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

class GmailBase:
    # If modifying these scopes, delete the file token.pickle.
    SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]
    def __init__(self, credentials_path):
        self.credentials_path = credentials_path
        self.service = self.build()

    def build(self):
        creds = None
        # The file token.pickle stores the user's access and refresh tokens, and is
        # created automatically when the authorization flow completes for the first
        # time.
        if os.path.exists("token.pickle"):
            with open("token.pickle", "rb") as token:
                creds = pickle.load(token)
        # If there are no (valid) credentials available, let the user log in.
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    self.credentials_path, self.SCOPES)
                creds = flow.run_local_server(port=0)
            # Save the credentials for the next run
            with open("token.pickle", "wb") as token:
                pickle.dump(creds, token)

        return build("gmail", "v1", credentials=creds)

class GmailApiHandler(GmailBase):
    def list_labels(self, userId="me"):
        """Lists the user's Gmail labels."""
        results = self.service.users().labels().list(
            userId=userId).execute()
        labels = results.get('labels', [])

        if not labels:
            print('No labels found.')
        else:
            print('Labels:')
            for label in labels:
                print("\t", label['name'])

    def find_messages(self, userId="me", count=10, query=""):
        """Returns the user's Gmail ids."""
        return self.service.users().messages().list(
            userId=userId, maxResults=count, q=query).execute()

    def message_detail(self, message_id, userId="me"):
        return self.service.users().messages().get(userId=userId, id=message_id).execute()
```

## usage

```python
gmail = GmailApiHandler("credentials.json")
gmail_ids = gmail.find_messages(count=1, query="UQ mobile データ通信量のご案内")
gmail_id = gmail_ids.get("messages")[0].get("id")
message_details = gmail.message_detail(gmail_id)

def show_mail(message_details):
    [subject] = list(filter(
        lambda x: x.get("name")=="Subject",
        message_details.get("payload").get("headers")
    ))
    print("title:", subject.get("value"))
    print("text: ", message_details.get("snippet"))

show_mail(message_details)
```

#### out

```
title: UQ mobile データ通信量のご案内（自動送信メール）
text:  2020/04/27 21:05:31 ID：hogehoge 様日頃よりUQ mobileをご利用いただき誠にありがとうございます。 ご契約回線のデータ通信量のご利用状況について、お知らせいたします。 データ残量がなくなった場合、月末までデータ通信の速度に制限がかかります。 【電話番号】 08000000000 【データプラン】 データ高速（999GB） 【基本データ残量※】 0 MB ※上記
```

### 日時とかデータ量とかの抽出

```python
import re

def extract(text):
    date = re.findall(r"\d{4}/\d{2}/\d{2}\ \d{2}:\d{2}:\d{2}", text)
    amount = re.findall(r"【基本データ残量※】\ (\d)*", text)
    return date, amount

text = message_details.get("snippet")

try:
    [date], [amount] = extract(text)
except:
    raise Exception(f"Undefined format: \n\t{text}")

print(date, amount) #> 2020/04/27 21:05:31 0
```

この本文内容を元にデータチャージ実行を行うかを判定し、データチャージの実行をさせると良さげ。

Gmail API の(初めてさわる)部分ができればあとは難しくないので、気が向けば続き描きます(多分書かない)
