---
title: "Speed Wi-Fi 接続端末からデータ通信量を確認する"
date: 2020-05-31T19:37:06+09:00
draft: false
toc: true
images:
tags:
  - python
---

## モチベーション

Speed Wi-Fi NEXT は直近 3 日の通信量が 10GB を超えると速度制限がかかるので, Mac からでもデータ通信量がわかるようにしたい。

## 参考

[【W01】Speed Wi-Fi NEXT 設定ツールにログインする方法は？ | よくあるご質問｜【公式】UQ WiMAX ｜ UQ コミュニケーションズ](https://faq.uqwimax.jp/faq/show/1613?site_domain=wimax)

## メインコード

```python
from loguru import logger

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


class BrowserOperator(object):
    def __init__(self, headless=False):
        options = Options()
        options.headless = headless
        self.driver = webdriver.Chrome(options=options)

    def __del__(self):
        self.driver.close()

    def wait(self, f, until_not=False):
        wt = 10
        try:
            if until_not:
                return WebDriverWait(self.driver, wt).until_not(f)
            return WebDriverWait(self.driver, wt).until(f)
        except TimeoutException:
            logger.error("[timeout]")
            return False

    def get(self, url):
        logger.debug(f"[get] {url}")
        self.driver.get(url)


class SpeedwifiNext(BrowserOperator):
    BASE = "http://speedwifi-next.home/html/"

    def login(self, user: str, pswd: str) -> None:
        self.get(self.BASE + "login.htm")

        self.driver.find_element_by_id("user_type").send_keys(user)
        self.driver.find_element_by_id("input_password").send_keys(pswd)
        self.driver.find_element_by_id("login").click()

        status = self.wait(EC.url_to_be(self.BASE + "status.htm"))
        if status:
            logger.debug("login success")
        else:
            raise Exception("login failed\nPlease check your User and Pass!")

    def statistics(self) -> None:
        self.get(self.BASE + "statistics.htm")
        self.wait(
            EC.text_to_be_present_in_element((By.ID, "label_usedData"), "0 KB"),
            until_not=True,
        )

        def f(x) -> str:
            return self.driver.find_element_by_id(x).get_attribute("innerText")

        print("1ヶ月間：", f("label_usedData"))
        print("前日までの3日間：", f("label_usedData_yesterday"))
        print("本日までの3日間：", f("label_usedData_today"))


if __name__ == "__main__":
    user = ""
    pswd = ""

    sn = SpeedwifiNext(headless=True)
    sn.login(user, pswd)
    sn.statistics()

```

## 動作確認

```
2020-05-31 19:34:22.570 | DEBUG    | __main__:get:31 - [get] http://speedwifi-next.home/html/login.htm
2020-05-31 19:34:25.238 | DEBUG    | __main__:login:47 - login success
2020-05-31 19:34:25.238 | DEBUG    | __main__:get:31 - [get] http://speedwifi-next.home/html/statistics.htm
1ヶ月間： 129.68 GB
前日までの3日間： 12.51 GB
本日までの3日間： 13.77 GB
```

## 後書き

python のログ関連ってあまり素直に使えないですよね[^1]

そんな中`Loguru`[^2]という ライブラリを見つけたので使ってみました。

- デフォルトのログレベルが DEBUG
- CUI カラー表示
- import するだけで使える

とかなり使い勝手が良かったです。今後簡単なデバックにも`print`に変わり使って行きたいなと思いました。

[^1]: [ログ出力のための print と import logging はやめてほしい - Qiita](https://qiita.com/amedama/items/b856b2f30c2f38665701)
[^2]: [Loguru Alternatives - Python Logging | LibHunt](https://python.libhunt.com/loguru-alternatives)
