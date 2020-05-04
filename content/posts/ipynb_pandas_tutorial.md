---
title: "Pandasの基本操作まとめ"
date: 2020-05-02T21:09:14+09:00
draft: false
toc: true
images:
tags:
  - python
  - colab
---

備忘録的メモ

この記事は Python 環境がなくても、`Google Colab`上で実際に動かすことができます。

## 実行環境

- [Google Colab](https://colab.research.google.com/?hl=ja)

```bash
! cat /etc/issue
Ubuntu 18.04.3 LTS \n \l

! python -V
Python 3.6.9

! pip show pandas | grep -e Name -e Version
Name: pandas
Version: 1.0.3
```

### ソースコード

https://colab.research.google.com/drive/1kodWef1HTaZeffIYQc7uyw4FTyvkr83F#forceEdit=true&sandboxMode=true

ソースコードの実行には Google アカウントが必要です。

また実行時 `警告: このノートブックは Google が作成したものではありません。` とポップアップが出ます。データや認証情報の読み取りが無いよう留意しておりますが、実行に際しては一度ソースコードを読んでから実行することをお願い申し上げます。

## Pandas とは

データ操作と分析のための Python ライブラリ

Excel のような 2 次元のテーブルを用いて構造化されたデータへのアクセスを行う。

csv, json, xlsx などに対応していて, インターネット上のソースファイルも利用できる

## データセットのダウンロード

今回は Titanic データセットを利用します。

https://www.openml.org/d/40945

Unix コマンドを用いてデータセットのダウンロードと簡単な中身の確認をしていきます。

```
curl -o titanic.csv https://www.openml.org/data/get_csv/16826755/phpMYEkMl
```

### 内容確認

```
head -n 3 titanic.csv && tail -n 3 titanic.csv

"pclass","survived","name","sex","age","sibsp","parch","ticket","fare","cabin","embarked","boat","body","home.dest"
1,1,"Allen, Miss. Elisabeth Walton","female",29,0,0,"24160",211.3375,"B5","S","2",?,"St Louis, MO"
1,1,"Allison, Master. Hudson Trevor","male",0.9167,1,2,"113781",151.55,"C22 C26","S","11",?,"Montreal, PQ / Chesterville, ON"
3,0,"Zakarian, Mr. Mapriededer","male",26.5,0,0,"2656",7.225,?,"C",?,304,?
3,0,"Zakarian, Mr. Ortin","male",27,0,0,"2670",7.225,?,"C",?,?,?
3,0,"Zimmerman, Mr. Leo","male",29,0,0,"315082",7.875,?,"S",?,?,?
```

### 行数確認

```
cat titanic.csv | wc -l

1310
```

## pandas の inport

```python
import pandas as pd
```

```python
# バージョン確認
pd.__version__ #> '1.0.3'
```

## データのインポート

```python
src = "titanic.csv"
df = pd.read_csv(src)
```

データソースが`json`の場合`pd.read_json(src)`, `excel`の場合`pd.read_excel(src)`のように直感的に読み込むことができます。

データソースがインターネット上にある場合(例えば
[COVID-19](https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv) )も`raw`ファイルを指定してあげることで同様に読み込むことができます。

```python
src = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
```

### 内容の確認

頭 5 行の表示

```python
df.head(5)
```

うしろ 5 行の表示

```python
df.tail(5)
```

カラムを表示

```python
df.columns
```

インデックスを表示

```python
df.index
```

値を表示

```python
df.values
```

各カラムのタイプを表示

```python
df.dtypes
```

```
pclass        int64
survived      int64
name         object
sex          object
age          object
sibsp         int64
parch         int64
ticket       object
fare         object
cabin        object
embarked     object
boat         object
body         object
home.dest    object
dtype: object
```

さらに詳しい DataFrame の基本情報を表示

```python
df.info()
```

```
RangeIndex: 1309 entries, 0 to 1308
Data columns (total 14 columns):
 #   Column     Non-Null Count  Dtype
---  ------     --------------  -----
 0   pclass     1309 non-null   int64
 1   survived   1309 non-null   int64
 2   name       1309 non-null   object
 3   sex        1309 non-null   object
 4   age        1309 non-null   object
 5   sibsp      1309 non-null   int64
 6   parch      1309 non-null   int64
 7   ticket     1309 non-null   object
 8   fare       1309 non-null   object
 9   cabin      1309 non-null   object
 10  embarked   1309 non-null   object
 11  boat       1309 non-null   object
 12  body       1309 non-null   object
 13  home.dest  1309 non-null   object
dtypes: int64(4), object(10)
memory usage: 143.3+ KB
```

## 基本統計

基本統計の表示

```python
df.describe()
```

全てのカラムにおける統計の表示

```python
df.describe(include="all")
```

## 行列の抽出

行の抽出

```python
df.loc[:, 'pclass']

# 以下のコードで同様の結果を得る
df.pclass
df["pclass"]
```

```
0       1
1       1
2       1
3       1
4       1
       ..
1304    3
1305    3
1306    3
1307    3
1308    3
Name: pclass, Length: 1309, dtype: int64
```

列の抽出

```python
df.loc[0]
```

```
pclass                                   1
survived                                 1
name         Allen, Miss. Elisabeth Walton
sex                                 female
age                                     29
sibsp                                    0
parch                                    0
ticket                               24160
fare                              211.3375
cabin                                   B5
embarked                                 S
boat                                     2
body                                     ?
home.dest                     St Louis, MO
Name: 0, dtype: object
```

## 特定の行列の抽出

行番号(index)が 100 から 104 の"pclass", "age"のカラム

```python
df.loc[range(100,105), ["pclass", "age"]]
```

単独要素の抜き出し

```python
df.at[1000, "ticket"]
```

```
'367228'
```

`loc`でも同様の結果を得るが、`at`の方が速い

```python
%%timeit
df.loc[1000, "ticket"]

    The slowest run took 14.63 times longer than the fastest. This could mean that an intermediate result is being cached.
    100000 loops, best of 3: 7.47 µs per loop

%%timeit
df.at[1000, "ticket"]

    The slowest run took 15.20 times longer than the fastest. This could mean that an intermediate result is being cached.
    100000 loops, best of 3: 4.26 µs per loop
```

## 複雑な抽出

`survived` カラムが `1` である列

```python
df[df["survived"] == 1]

df.query('survived == 1')
```

`embarked` カラムが `C` or `S` である列

```python
df[df["embarked"].isin(["C", "S"])]

df.query('embarked in ["C", "S"]')
```

`name` が `A` で始まる列

```python
df[df["name"].str.startswith("A")]
```

`name` が `e` で終わる列

```python
df[df["name"].str.endswith("e")]
```

`name` に `z` が含まれる列

```python
df[df["name"].str.contains("z")]
```

`name` に 別称(`()`で囲まれた名前)が含まれる列

```python
df[df["name"].str.match("._\([^\)]_\).\*")]
```

## dtype の変更

`age` カラムは `int` もしくは `float` で表されて欲しいが、現状 `Object` で認識されている

```python
df["age"].dtype #> dtype('O')
```

`age` カラムで数値以外の文字が含まれるものを抽出してみると、`?`が含まれることがわかった。

```python
set(df[df["age"].str.match("[^\d]")]["age"]) #> {'?'}
```

なので`?`を`NaN`に変更してやれば、`float`への変換ができる。

```python
# 数値以外の文字列をNaNで置換
df["age"] = df["age"].replace({'?': 'NaN'})

# dtypeの変更
df["age"] = df["age"].astype(float)
```

以下のよう`mask` や `where` を使う手もある

`df["age"] = df["age"].mask(df["age"].str.match("[^\d]"))`

`df["age"] = df["age"].where(df["age"].str.match("\d"))`

## 欠損地の扱い

`?` を `NaN`に置換して、`float`データとして扱わせる為、`NaN`は欠損値として扱われることになる。

欠損値でないものの数

```python
df["age"].count().sum() #> 1046
```

欠損値の数

```python
df["age"].isnull().sum() #> 263
```

欠損値がある行の表示

```python
df[df['age'].isnull()]
```

欠損値を持つ行の削除 `dropna()`

```python
len(df.copy().dropna().index) #> 1046
```

欠損値を持つ列の削除 `dropna(axis=1)`

```python
len(df.copy().dropna(axis=1).columns) #> 13
```

欠損値を 0 で置換 `fillna(0)`

```python
df.fillna(0).at[15,"age"] #> 0.0
```

欠損値を平均値で置換 `df.fillna(df.mean())`

```python
df.fillna(df.mean()).at[15,"age"] #> 29.8811345124283
```

中央値 `median()`

最頻値 `mode()`

欠損値を前の値で置換 `df.fillna(method='ffill')`

````python
df.fillna(method='ffill').loc[[14, 15, 16]]

欠損値を後ろの値で置換 `df.fillna(method='bfill')`
```python
df.fillna(method='bfill').loc[[14, 15, 16]]
````
