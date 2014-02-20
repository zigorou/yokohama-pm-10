# Introduction JSON Schema and perl-JSV

* Toru Yamaguchi <zigorou at cpan dot org>
* Yokohama.pm #10
* 2014/02/21

最初、Keynoteで書き始めたけど体裁気にして書くのが面倒なのでMarkdownにて失敬！

## Introduction

[json-schema.org](http://json-schema.org/)が公式です。
現在はdraft-04まで出ています。

仕様の説明は後に回すとして、重要な点を列挙していきます。

* XMLというデータ表現に対してXML SchemaやRELAX NGというデータ定義を提供する枠組み
* JSONというデータ表現に対してJSON Schemaというデータ定義を提供する枠組み

という対比が出来ます。

JSON(JavaScript Object Notation)について今更説明は不要だと思いますが、
手軽にデータを突っ込むには手軽なデータフォーマットです。

このJSONで表現されるデータに対してデータ定義を提供するSchemaを記述する為の枠組みがJSON Schemaです。

物は試しで、まず以下のようなデータがあるとしましょう。

```javascript
{
  "id": 501566911, 
  "name": "Toru Yamaguchi", 
  "birthday": "1976-12-24"
}
```

このデータに対してちょっと荒くJSON Schemaのsyntaxを使ってスキーマを記述すると以下のようになります。

```javascript
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "minimum": 0
    },
    "name": { "type": "string" },
    "birthday": { 
      "type": "string",
      "format": "date-time"
    }
  }
}
```

あまり説明する必要は無いと思いますが、素直に理解出来ますよね。これがJSON Schemaです。
つまり、JSON Schemaは

* JSONで表現可能なデータにデータ型を定義し記述する事が可能です
* 簡単で人間にも(それなりに)分かりやすく、もちろん machine readable でもある「仕様ドキュメント」になりえます

と言った特徴を挙げる事が出来ます。

で、今日はYokohama.pmな訳なのでPerlに関係ある話をしようじゃないかと言う訳で、例えばPerlのデータとして以下のような物があったとしましょう。

```perl
my $instance = {
  id       => 501566911, 
  name     => "Toru Yamaguchi", 
  birthday => "1976-12-24",
};
```

良くありますよね？そこで[JSV](https://github.com/zigorou/perl-JSV)モジュールの登場です。
サンプルコードとして[hello_jsv.pl](./hello_jsv.pl)を見て下さい。

動かせばすぐ分かりますよね。JSON SchemaはPerlで表現されたデータ構造に対してもValidationを行う事が出来ます。
細かい話は抜きにして、

* データ型を定義するだけでなく、データの検証に使える

という特徴を持っているのが分かると思います。

## JSON Schema tutorial

さて、全部を説明するのには時間も元気もあまりに足りないので要点だけ駆け足にて説明しますよ。

* (JSON Schema Core draft-04)[http://tools.ietf.org/html/draft-zyp-json-schema-04]
* (JSON Schema Validator draft-00)[http://tools.ietf.org/html/draft-fge-json-schema-validation-00]

についてです。

### プリミティブ型について

[3.5. JSON Schema primitive types](http://tools.ietf.org/html/draft-zyp-json-schema-04#section-3.5)にある通りなんですが、
JSON Schema内で取り扱うプリミティブな型には以下のデータ型があります。

* array
* boolean
* integer
* number
* null
* object
* string

JSON Schemaを使ってスキーマを記述する際にはこれらのプリミティブ型をベースにして様々な制約(keywordと言います)をつけて行く事によってデータ型を表現して行く事になります。

Perlのデータ型と比較すると次のような感じでしょうか。

| JSON Schema primitive type | Perl Data type |
|:--------------------------:|:---------------|
| array | ARRAYREF |
| boolean | Perlにbooleanとかねーよ！！！ |
| integer | SCALAR (IV) |
| number | SCALAR (NV) |
| null | undef |
| object | HASHREF |
| string | SCALAR (SV) |

booleanとか忘れて下さい＞＜

Perlで取り扱う際にはJSVでは二通りのケースを考えておりまして、

* JSON由来のデータに対して厳密に評価するモード(default)
* LLっぽぃゆるふわなデータに対してゆるふわに評価するモード (loose_typeオプション)

の二つをご用意しております。loose_typeオプションが捗る話は後で書く。
