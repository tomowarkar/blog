---
title: "はてなブログ自動投稿Pythonスクリプト"
date: 2020-04-09T01:46:56+09:00
draft: false
toc: true
images:
tags:
  - python
  - hatena
  - automation
---

はてなブログの投稿を自動化、ローカル管理がしたい

ということで Hatena api を叩いてみた備忘録

## 参考

- [はてな API 一覧](http://developer.hatena.ne.jp/ja/documents/apis)

## 下準備

ローカルでの記事管理は以下のようなものを想定する

- markdown 形式
- 1 行目にブログタイトル
- 2 行目にブログタグ
- 3 行目以降は本文

### example.md

```markdown
タイトル
Python,日常,hoge

## 今日の

hugahuga

### 天気は

hogahoga
```

ローカルでの投稿済みか未投稿かの判別や、投稿日時の判別は対応できないが最低限の仕様ではあると思う。

## Python スクリプト

### main.py

```python
from datetime import datetime
import requests as req

HATENA_ID = "your hatena id"
BLOG_DOMAIN = "your blog domain"
API_KEY = "your api key"
BASE_URL = f"https://blog.hatena.ne.jp/{HATENA_ID}/{BLOG_DOMAIN}/atom"


def hatena_entry(title, content, categorys=[], updated="", draft=False):
    """はてなブログへの投稿
    Attributes:
      HATENA_ID, API_KEY, BASE_URL (str)

    Args:
      title (str):
      content (str):
      categorys (List[str]):
      updated (str): %Y-%m-%dT%H:%M:%S
      draft (bool):

    Returns:
      str: xml
    """
    updated = updated if updated else datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    draft = "yes" if draft else "no"
    category = lambda x: "\n".join([f"<category term='{e}' />" for e in x])
    categorys = category(categorys) if category else ""

    xml = f"""<?xml version="1.0" encoding="utf-8"?><entry xmlns="http://www.w3.org/2005/Atom" xmlns:app="http://www.w3.org/2007/app">
      <title>{title}</title><author><name>name</name></author><content type="text/markdown">{content}</content>
      <updated>{updated}</updated>{categorys}<app:control><app:draft>{draft}</app:draft>
      </app:control></entry>""".encode(
        "UTF-8"
    )
    r = req.post(BASE_URL + "/entry", auth=(HATENA_ID, API_KEY), data=xml)
    return r.text


if __name__ == "__main__":
    import sys

    _, arg = sys.argv
    with open(arg, "r") as f:
        title, categorys, *content = f.readlines()
    categorys = categorys.split(",")
    content = "\n".join(content)
    r = hatena_entry(title, content, categorys)
    print(r)

```

はてなブログの api では xml を扱う。これまで xml にあまり触れてこなかったが、自動投稿ぐらいだと大して詰まることもなく書けた。

## usage

```
python3 main.py example.md
```
