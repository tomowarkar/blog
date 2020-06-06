---
title: "opencv ランダムノイズ画像の生成"
date: 2020-06-06T16:16:14+09:00
draft: false
toc: true
images:
tags:
  - python
  - 画像処理
---

忘れるので備忘録

## コード

```python
import cv2
import numpy as np
from tqdm import tqdm

h, w = 400, 600
size = (w, h)
fps = 60
filename = "hoge.mp4"

fourcc = cv2.VideoWriter_fourcc("m", "p", "4", "v")
video = cv2.VideoWriter(filename, fourcc, fps, size)

for _ in tqdm(range(fps * 10)):
    img = np.random.randint(0, 256, (h, w, 3), np.uint8)
    video.write(img)
video.release()

```

## 画像を用いる場合

```python
img = cv2.imread("path/to/img", 1)
h, w, _ = img.shape
```
