---
title: "spaCyを使ってみた ~レンマ化とステミングの違い~"
date: 2020-05-04T22:19:10+09:00
draft: false
toc: true
images:
tags:
  - python
  - nlp
---

2020 年版 [言語処理 100 本ノック 第 6 章](https://nlp100.github.io/ja/ch06.html) で自然言語処理ライブラリの`spaCy`を使った備忘録

Google Colab では標準で入っているので簡単に試してみるにはおすすめ

### 参考

[spaCy 101: Everything you need to know](https://spacy.io/usage/spacy-101)

[spaCy 101: Everything you need to know 和訳](https://qiita.com/miorgash/items/0eda4adcc8d9ecd143e6)

## 環境

Google Colab

```
! python -V
! pip show spacy
Python 3.6.9
Name: spacy
Version: 2.2.4
Summary: Industrial-strength Natural Language Processing (NLP) in Python
```

## トークン化

```python
import spacy
nlp = spacy.load("en_core_web_sm")

doc = nlp("So foul and fair a day I have not seen.")

tokens = [e for e in doc]
print(tokens) # > [So, foul, and, fair, a, day, I, have, not, seen, .]
```

```python
token = tokens[5]
print(token.text, token.lemma_, token.pos_, token.tag_,
    token.dep_, token.shape_, token.is_alpha, token.is_stop)
    # > day day NOUN NN npadvmod xxx True False
```

右から原文, 基本語形, 品詞, 詳細, 統計, 語形, 英字, ストップワードの順

> Text: The original word text.
> Lemma: The base form of the word.
> POS: The simple part-of-speech tag.
> Tag: The detailed part-of-speech tag.
> Dep: Syntactic dependency, i.e. the relation between tokens.
> Shape: The word shape – capitalization, punctuation, digits.
> is alpha: Is the token an alpha character?
> is stop: Is the token part of a stop list, i.e. the most common words of the language?
> 参照: spaCy 101: Everything you need to know より

```python
# 品詞によるフィルター
token_noun = [e for e in doc if e.pos_ in ["NOUN"]]
print(token_noun) # > [day]

# ストップワードを除外
token_excl_sw = [e for e in doc if not e.is_stop]
print(token_excl_sw) # > [foul, fair, day, seen, .]

# 最低限のクリーニングをするなら。
token_tidy = [e for e in doc if e.pos_ not in ["PUNCT", "SYM", "SPACE"]]
print(token_tidy) # > [So, foul, and, fair, a, day, I, have, not, seen]
```

参考: [Syntactic Dependency Parsing](https://spacy.io/api/annotation#section-pos-tagging)

### 固有表現

```python
doc = nlp("Apple bought 10 apples for 100 billion yen.")
for ent in doc.ents:
    print(ent.text, ent.start_char, ent.end_char, ent.label_)
```

##### out

数字の有意性を図るのに使えそう?

```
Apple 0 5 ORG
10 13 15 CARDINAL
100 billion yen 27 42 MONEY
```

### 単語ベクトルと類似性

末尾に`sm`とつく`en_core_web_sm`のような言語モデルでは単語ベクトルが含まれておらず精度が低い。

また実行時に`ModelsWarning: [W007] The model you're using has no word vectors loaded, so the ...`と警告される。

言語モデルを確認のこと、データ量の大きいモデルをダウンロードすると良い

```
# python -m spacy download en_core_web_md
python -m spacy download en_core_web_lg
```

またさらに上記コードでモデルをダウンロードして、いざ`nlp = spacy.load("en_core_web_lg")`で扱おうとしても
`OSError: [E050] Can't find model 'en_core_web_lg'. It doesn't ...`モデルみつかんねーよとエラーが出る場合がある(jupyter notebook や google colab で発現?)

参考: [spaCy issues #4577](https://github.com/explosion/spaCy/issues/4577)

上記 issue にもあるように以下コードで修正した

```python
import en_core_web_lg
nlp = en_core_web_lg.load()
```

#### 類似性

```python
dog = nlp("dog")
cat = nlp("cat")
apple = nlp("apple")

print(dog.text, cat.text, dog.similarity(cat))
print(dog.text, apple.text, dog.similarity(apple))
```

2 つのモデル(`en_core_web_sm`, `en_core_web_lg`)の類似度の結果をそれぞれ載せておく

```
# モデル en_core_web_sm
dog cat 0.6549556828973659
dog apple 0.6209418867452425

# モデル en_core_web_lg
dog cat 0.8016854705531046
dog apple 0.2633902481063797
```

`sm`の方は犬と猫とりんごもそんな変わらない結果となっている。データ量は偉大。

## ハッシュ化

自分でやろうとしたら管理が面倒なので, 便利だなーって思ったやつ

文字列にハッシュ 値が割り振られている

```python
nlp.vocab.strings["apple"] # > 8566208034543834098

nlp.vocab.strings[3197928453018144401] # > 'coffee'
```

```python
lexeme = nlp.vocab[apple.text]
print(lexeme.text, lexeme.orth, lexeme.shape_, lexeme.prefix_, lexeme.suffix_,
            lexeme.is_alpha, lexeme.is_digit, lexeme.is_title, lexeme.lang_)
# > apple 8566208034543834098 xxxx a ple True False False en
```

> Text: The original text of the lexeme.
> Orth: The hash value of the lexeme.
> Shape: The abstract word shape of the lexeme.
> Prefix: By default, the first letter of the word string.
> Suffix: By default, the last three letters of the word string.
> is alpha: Does the lexeme consist of alphabetic characters?
> is digit: Does the lexeme consist of digits?
> 参照: spaCy 101: Everything you need to know より

## ステミング

spaCy は Stemming(ステミング)に対応しておらず、代わりに レンマ化(Lemmatization)を使うこととなります。

ステミングとレンマ化の違いを説明しろと言われてもまだあまり理解しておらず少し難しいので、`nltk`のスノーボールステマーと簡単な比較をしてみます。

#### Lemmatization

```python
doc = nlp("compute computer computed computing computation")
for token in doc:
    print(token.text+ ' --> ' + token.lemma_)
```

#### Stemming

```python
from nltk.stem.snowball import SnowballStemmer

stemmer = SnowballStemmer(language='english')
tokens = "compute computer computed computing computation".split()

for token in tokens:
    print(token + ' --> ' + stemmer.stem(token))
```

##### out

```
# Lemmatization
compute --> compute
computer --> computer
computed --> compute
computing --> compute
computation --> computation

# Stemming
compute --> comput
computer --> comput
computed --> comput
computing --> comput
computation --> comput
```

#### ステミングとレンマ化の違い 2

判別の難しい`saw`を使って違いを見てみます。
比較する文は`a power saw`と`I saw the apple`で, 結果のみを記します。

```
# a power saw (Lemmatization)
a --> a
power --> power
saw --> see

# a power saw (Stemming)
a --> a
power --> power
saw --> saw

# I saw the apple (Lemmatization)
I --> -PRON-
saw --> see
the --> the
apple --> apple

# I saw the apple (Stemming)
I --> i
saw --> saw
the --> the
apple --> appl
```

レンマ化ではノコギリの方の`saw`を`see`と誤認していますし、ステミンングでは`saw`を`see`と見抜けていません
。またステミンングでは`apple --> appl`となっています。

この辺りがステミングとレンマ化の違いと言えるのではないでしょうか。

ステミングでは主に接尾の除去による処理が行われ、レンマ化では辞書参照が行われているという認識でしょうか?

とはいえステミングとレンマ化の違いは手段の違いでしかないので、目的に合わせて判断やチューニングするのが大事でしょう。(自分は目的がうまく達成されるならどっちでもいいと捉えます)

#### 眺めた記事たち

- [Python for NLP: Tokenization, Stemming, and Lemmatization with SpaCy Library](https://stackabuse.com/python-for-nlp-tokenization-stemming-and-lemmatization-with-spacy-library/)
- [【python】nltk で英語の Stemming と Lemmatization](https://www.haya-programming.com/entry/2018/03/25/203836)
- [What is the difference between lemmatization vs stemming?](https://stackoverflow.com/questions/1787110/what-is-the-difference-between-lemmatization-vs-stemming)
- [What-are-the-advantages-of-Spacy-vs-NLTK](https://www.quora.com/What-are-the-advantages-of-Spacy-vs-NLTK)

## おわりに

英語での自然言語処理を始めようとしたとき、機械的に空白で tokenize して、正規表現でクリーニングして、 `nltk`のスノーボールステマーでステミングして... と考えていたものが`spaCy`でほぼ実装できてしまいました。

深いレベル(自分でモデルのチューニングをする)の場合は分かりませんが、とりあえず自然言語処理をやってみるという点でこの`spaCy`は最高に使いやすかったです。

英語の自然言語処理は進んでるなーって感じです(こなみ)

- [8 best Python Natural Language Processing (NLP) libraries](https://sunscrapers.com/blog/8-best-python-natural-language-processing-nlp-libraries/)

P.S.　いくら`spaCy`が高速な言語解析ツールだからといって 10000 行を超える処理をさせると数分かかる(処理速度 ms 単位)
