---
title: "コマンドラインからyoutubeの再生リストを取得する"
date: 2020-04-28T12:26:31+09:00
draft: false
toc: true
images:
tags:
  - bash
  - youtube
  - regex
---

## チャンネル ID 抜き出し

```bash
$ echo https://www.youtube.com/user/HikakinTV/videos | cut -d "/" -f 5
HikakinTV
```

## タイトルを取得

```bash
$ curl -s https://www.youtube.com/user/HikakinTV/videos | grep "yt-lockup-title" | sed -e "s/.*title=\"\([^\"]*\)\".*/\1/g"
【悲報】新iPhone SE全色自分ごと水没！４万円台で買えるコスパ抜群のiphone!【開封レビュー】【カメラ比較】【ヒカキンTV】
スーパー店員時代のヤバい話・変なお客さん【金隠しおじさん&amp;クーラーおじさん】
国からもらったマスク誕生日に開封レビューしてみたw【31歳】
【悲報】ヒカキン、斉藤さんでブチギレられる…コロナのこと聞いたら危機感ないので注意してみた
ヒカキン×香取慎吾の質問コーナーで裏話や突っ込んだこと沢山聞けましたwww
1000万円のヒカキンゲームスタジオついに完成！【ゲーミングPC】
小池都知事にコロナのこと質問しまくってみた【ヒカキンTV】【新型コロナウイルス】
【開封】ニンテンドースイッチどうぶつの森セット&amp;スイッチライトコーラル！【Nintendo Switch】
僕の地元でコロナが。緊急事態宣言が出ても帰省は控えよう【拡散希望】
店員さんに優しくしてあげよう。
【削除覚悟】きりたんぽ同士で無理やり共食いさせてみた…【衝撃映像】
自宅で本気の味噌ラーメン作ったらお店レベルにwww【麺処くるり】【ヒカキン&amp;セイキン】
LINEでビデオ通話したら香取慎吾さんドッキリ【後編】ユーチューバーにかけまくるw【ヒカキンTV】
若いみんなへ、ヒカキンより。
LINEでビデオ通話したら香取慎吾さんドッキリ【前編】ユーチューバーにかけまくるw【ヒカキンTV】
【ドッキリ】デカキンUUUM加入！サプライズで大号泣!?【UUUM新オフィス紹介】
【ドッキリ】デカキンに無断で２人一緒に金髪にしてみたら発狂w【ヒカキンも金髪】
【費用????万円】渋谷に超巨大ヒカキントラック走らせてみたwww
BTSに間違われて空港がパニックになりました…【ヒカキンTV】
卒業式が出来なかったみんなへ、ヒカキンより。
【感動】まるおともふこがもう一匹の兄弟と再会！もふこに超ソックリでビックリ!?【家族再会】
【拡散希望】マスク詐欺が許せない。その手口と被害防止について【家族を守ろう】【注意喚起】
炎上中に質問100個答えますw【登録者800万人記念生配信】
【デマで炎上】トイレットペーパー不足はヒカキンが買い占めたせい【マスク不足について】
人間より大きい超巨大わたあめ作ったら大変すぎたwww
【旅動画】総額120万円の高級ニューヨーク旅 &amp; ヒカキン流緊急パッキング！【NewYork旅行】
【ランキング】ヒカキンが選ぶマジでウマいセブンのおにぎりTOP５発表！
ママと初めてのウーバーイーツ食べ放題で大パニックwww【Uber Eats】
【わたあめ王決定戦】わたあめ作り＆ 大食いバトルで１位は誰だ!!!【ヒカキンvs関根りさvsマスオ】
【超簡単】カップヌードルチャーハンを７種類作って1位を決めたらまさかの結果に!!【炒飯】
```

## 動画 URL を取得

```bash
$ curl -s https://www.youtube.com/user/HikakinTV/videos | grep "yt-lockup-title" | sed -e "s/.*href=\"\([^\"]*\)\".*/https:\/\/www.youtube.com\1/g"
https://www.youtube.com/watch?v=zPHERhDPIJM
https://www.youtube.com/watch?v=KAfULYulCJM
https://www.youtube.com/watch?v=RlVB-Q8eLHk
https://www.youtube.com/watch?v=b0k-fdXk28c
https://www.youtube.com/watch?v=DEuruU-doQM
https://www.youtube.com/watch?v=cEdeotYQMCM
https://www.youtube.com/watch?v=ofCsslfc-So
https://www.youtube.com/watch?v=rzziAEhCJhI
https://www.youtube.com/watch?v=YybcDn5BJAg
https://www.youtube.com/watch?v=o_lfRo1_52c
https://www.youtube.com/watch?v=Qq0_H0Zx51E
https://www.youtube.com/watch?v=VRovUa1ioOw
https://www.youtube.com/watch?v=lWEb0E1LmjE
https://www.youtube.com/watch?v=ThfRyRj_1KI
https://www.youtube.com/watch?v=V27iErwCs2E
https://www.youtube.com/watch?v=iI7Nx3nXrdk
https://www.youtube.com/watch?v=YvCQ1UZeHnA
https://www.youtube.com/watch?v=E0jUYAfFHIM
https://www.youtube.com/watch?v=D5gd_0dhQ00
https://www.youtube.com/watch?v=VbHHk-Qw_nw
https://www.youtube.com/watch?v=55dkC87QFU8
https://www.youtube.com/watch?v=pqQDCOWtcZY
https://www.youtube.com/watch?v=g8c0psnuDc8
https://www.youtube.com/watch?v=rPTKNk1vU5w
https://www.youtube.com/watch?v=WtYprWCWaVA
https://www.youtube.com/watch?v=1LaaEldNh0Q
https://www.youtube.com/watch?v=Np0xscEb3Dw
https://www.youtube.com/watch?v=W5r3Y2TPZHo
https://www.youtube.com/watch?v=anWsme7SRSs
https://www.youtube.com/watch?v=jGbevSbPwOI
```

{{<image src="https://i.imgur.com/ZE6z532.png" alt="blog top page" position="center">}}

うまくいってそう

### memo

- 変更差分を取れば新規動画投稿のトリガーになりそう

```bash
$ curl -s https://www.youtube.com/user/HikakinTV/videos | grep -c "yt-lockup-title"
30
```

- 最新 30 件以上の動画の取得は`JavaScript`を用いた通信が用いられているためコマンドラインだけでは無理?
- Chrome driver とか使う方が良さそう
- grep 　正規表現の最短一致の記述がわからない `"`内の最短一致を今回は`\"\([^\"]*\)\"`この様に実装
- python だと`\"(.*?)\"`これでいけた気がする
- バックスラッシュの使い方が癖あるなぁ

参考: [grep でこういう時はどうする?](https://qiita.com/hirohiro77/items/771ffb64dddceabf69a3)

## 変更差分の取得例

簡単化のためテキストファイルを 5 行にして示す.

```bash
$ curl -s https://www.youtube.com/user/HikakinTV/videos | grep "yt-lockup-title" | sed -e "s/.*href=\"\([^\"]*\)\".*/https:\/\/www.youtube.com\1/g" > hikakin`date +%y%m%d`.txt

$ cat -b hikakin200427.txt hikakin200428.txt
     1	https://www.youtube.com/watch?v=KAfULYulCJM
     2	https://www.youtube.com/watch?v=RlVB-Q8eLHk
     3	https://www.youtube.com/watch?v=b0k-fdXk28c
     4	https://www.youtube.com/watch?v=DEuruU-doQM
     5	https://www.youtube.com/watch?v=cEdeotYQMCM
     1	https://www.youtube.com/watch?v=anWsme7SRSs
     2	https://www.youtube.com/watch?v=jGbevSbPwOI
     3	https://www.youtube.com/watch?v=KAfULYulCJM
     4	https://www.youtube.com/watch?v=RlVB-Q8eLHk
     5	https://www.youtube.com/watch?v=b0k-fdXk28c

$ diff hikakin200427.txt hikakin200428.txt | grep "^>\ " | awk '{print $2}'
https://www.youtube.com/watch?v=anWsme7SRSs
https://www.youtube.com/watch?v=jGbevSbPwOI
```

本件関係ないけど`diff`に関して 1 へぇ[diff でコマンドの出力の結果を直接比較する。](https://qiita.com/wingedtw/items/2f05c5d0c37d71f209f4)
