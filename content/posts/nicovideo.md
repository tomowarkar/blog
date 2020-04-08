---
title: "ニコニコ動画のチャンネルにおける動画のurlリストを取得するPythonスクリプト"
date: 2020-04-08T23:04:57+09:00
draft: false
toc: false
images:
tags:
  - niconico
  - selenium
  - python
---

```python
from time import sleep
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

MAIL = "" #ログインに使うメールアドレス
PSWD = "" #ログインに使うパスワード

class NicoVideo(object):
    """ニコニコ動画の操作を行う
    Args:
      headless (bool): ヘッドレスモード使用の有無
    Attributes:
      driver: selenium.webdriver.chrome.webdriver.WebDriver
    """
    def __init__(self, headless=False):
        options = Options()
        options.headless = headless
        self.driver = webdriver.Chrome(options=options)

    def __del__(self):
        self.driver.close()

    def login(self, mail, pswd):
        """ニコニコ動画へのログイン
        Args:
          mail (str)
          pswd (str)
        Returns:
          None
        """
        url = "https://account.nicovideo.jp/login"
        self.driver.get(url)
        print("[driver] get", url)
        self.driver.find_element_by_id("input__mailtel").send_keys(mail)
        self.driver.find_element_by_id("input__password").send_keys(pswd)
        self.driver.find_element_by_id("login__submit").submit()

    def channel_video_list(self, channel_name, page=1):
        """ニコニコ動画のあるチャンネルにおける動画のURLリストの取得
        Args:
          channel_name (str): channel name
          page (int): page num　( > 0 )
        Returns:
          List[str]
        """
        url = f"https://ch.nicovideo.jp/{channel_name}/video?page={page}"
        self.driver.get(url)
        print("[driver] get", url)

        items = self.driver.find_elements_by_css_selector("ul.items > li.item")

        return [
            item.find_element_by_css_selector("div.item_left > a").get_attribute("href")
            for item in items
        ]


if __name__ == "__main__":
    output_file = "nicovideo.txt"

    # ファイルの初期化
    with open(output_file, "w"):
        pass

    nv = NicoVideo(headless=True)
    nv.login(MAIL, PSWD)

    page = 1
    while True:
        channel_name = "mentalist"
        vlist = nv.channel_video_list(channel_name, page=page)
        if not vlist:
            break
        text = "\n".join(vlist) + "\n"
        with open(output_file, "a") as f:
            f.write(text)

        page += 1

```
