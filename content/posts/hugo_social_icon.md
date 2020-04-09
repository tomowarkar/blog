---
title: "HugoのソーシャルアイコンにQiitaアイコンを追加した備忘録"
date: 2020-04-09T15:33:43+09:00
draft: false
toc: false
images:
tags:
  - hugo
---

{{<image src="https://i.imgur.com/AYyMNK5.png" alt="blog top page" position="center">}}


当然といえば当然だが、hello-friend-ngの[README](https://github.com/itsjoeoui/hugo-theme-hello-friend-ng#user-content-available-social-icons)にもあるように、ソーシャルアイコンにQiitaは対応していない。


そこに画像(もしくはこのブログの[トップページ](https://tomowarkar.github.io/blog/))のようにqiitaアイコンを追加したという備忘録。


対応するコミットは[こちら](https://github.com/tomowarkar/blog/commit/6b88f224fa1d6e473be03875255b211e4367670c)




## はじめに

### テーマの管理に関して
- hugoでのテーマは`themes` フォルダの配下でサブモジュールとして管理されている。
- 直接ソースコードをいじればもちろん変更は可能だが、サブモジュール自体のアップデートがあった時に変更が消えてしまう。
- なので直接ソースをいじるのは無し(wordpressのテーマなどでもお馴染みではあるが)



### ソーシャルアイコンに関して
今現在私が使わせてもらっているテーマは[hugo-theme-hello-friend-ng](https://github.com/itsjoeoui/hugo-theme-hello-friend-ng)

- READMEを読んでいくとソーシャルアイコンは[simpleicons](https://simpleicons.org/)のアイコンを使っている。
- テーマ内でのアイコン管理はどうやら[ここ](https://github.com/itsjoeoui/hugo-theme-hello-friend-ng/blob/master/layouts/partials/svg.html)で行っている。



### テーマ編集に関して
どうやら`layouts`配下に仕様しているテーマの変更したいソースコードパスをコピーしてこればいいらしい。(参考サイト忘れてしまいました。すいません。)

なので

```bash
cp blog/themes/hello-friend-ng/layouts/partials/svg.html blog/layouts/partials/
```

このようにコピーして,コピーしたものを編集すればHugoさんがよしなにしてくれる。


##### layouts/partials/svg.html
```html
+ {{- else if (eq .name "qiita") -}}
+     <svg xmlns="http://www.w3.org/2000/svg" width="26" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path xmlns="http://www.w3.org/2000/svg" d="M7.883 11.615c0-1.92-1.474-3.904-3.974-3.904C1.987 7.71 0 9.183 0 11.679c0 1.92 1.474 3.905 3.973 3.905.801 0 1.602-.256 2.275-.736L7.402 16l.513-.512-1.09-1.088c.673-.736 1.058-1.696 1.058-2.785zm-3.974-3.2c1.827 0 3.269 1.408 3.269 3.232 0 1.569-1.218 3.233-3.237 3.233-2.018 0-3.236-1.632-3.236-3.2 0-2.049 1.634-3.265 3.204-3.265zm5.864 1.568h.673v5.44h-.673zm.32-.736a.574.574 0 0 1-.576-.576c0-.32.256-.576.576-.576.32 0 .577.256.577.576 0 .32-.256.576-.577.576zm2.724 0a.574.574 0 0 1-.577-.576c0-.32.257-.576.577-.576.32 0 .577.256.577.576 0 .32-.256.576-.577.576zm-.32.736h.673v5.44h-.673zm4.71 5.537c-1.25 0-1.987-.96-1.987-1.92V8.479h.673v1.504h2.371v.672h-2.37v2.977c0 .608.48 1.248 1.313 1.248.224 0 .449-.064.64-.192l.065-.032.32.576-.064.032c-.288.16-.64.256-.961.256zm4.454.032c-1.827 0-2.916-1.44-2.916-2.848 0-1.825 1.442-2.913 2.852-2.913.737 0 1.314.256 1.73.736v-.544H24v5.44h-.673v-.607c-.384.48-.961.736-1.666.736zm-.064-5.089c-1.09 0-2.18.832-2.18 2.24 0 1.089.834 2.177 2.244 2.177.64 0 1.282-.288 1.698-.8v-2.817a2.29 2.29 0 0 0-1.762-.8z"/></polygon></svg>
{{- end -}}
```

あとの変更は[こちら](https://github.com/tomowarkar/blog/commit/6b88f224fa1d6e473be03875255b211e4367670c)の通り。お手軽にテーマの編集ができた。

※ docs/index.html は自動生成されたもの。

