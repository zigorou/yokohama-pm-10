# Introduction JSON Schema and perl-JSV

* Toru Yamaguchi <zigorou at cpan dot org>
* Yokohama.pm #10
* 2014/02/21

最初、Keynoteで書き始めたけど体裁気にして書くのが面倒なのでMarkdownにて失敬！
今日話すのは[JSON Schema](http://json-schema.org/)という仕様の話と、[JSV](https://github.com/zigorou/perl-JSV)モジュールについてです。

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

### 最小構成のスキーマとJSON Schemaのスキーマの話

見出し、何言ってるか分からないかもしれませんが、要はself-desriptiveですよって話です。
つまりJSON Schemaを使ってスキーマデータのsyntaxを定義出来ちゃうって意味です。

JSON Schemaのスキーマは[github上にあるdraft-04のcoreファイル](https://github.com/json-schema/json-schema/blob/master/draft-04/schema)が読みやすくて便利です。
このcoreスキーマを解説していきたい所ではあるのですが、結論から先に言ってしまうと最小構成のスキーマは以下になります。

```javascript
{}
```

お前は何を言っているんだと思うかもしれませんが本当です。
で、この最小構成のスキーマはどういう意味かと言うと、いかなるデータもvalidであるという意味になります。まぁ、考えてみれば自然ですね。

以下、うんちくです。後で各自目を通す事。

* typeキーワードがobject([L28](https://github.com/json-schema/json-schema/blob/master/draft-04/schema#L28))なのでスキーマはobject型でなければなりません
* このobjectの持ちうるプロパティはpropertiesキーワード内([L29](https://github.com/json-schema/json-schema/blob/master/draft-04/schema#L29))で定義されています
  * ちなみにここで定義されているフィールド名の部分がJSON Schemaを用いて書いたスキーマ内で使えるkeyword郡です
* これは傍証ですがdefaultにempty objectが指定されている([L149](https://github.com/json-schema/json-schema/blob/master/draft-04/schema#L149))ので、空のobjectが最小構成のスキーマになります
  * 真面目に言えばpropertiesキーワード内での指定だけでは、そのようなフィールドが登場した場合の値に対する定義をしただけで、そのようなフィールドが存在しなくてはならない訳ではないです
  * もう少し突っ込んで言えばrequiredキーワードを用いて指定されたフィールド名があれば、そのフィールドが登場しないとvalidではないと言う意味になります

ここでdefaultキーワードに対して少し言及しておきます。これはJSON Schema仕様では[metadata keywordとして分類](http://tools.ietf.org/html/draft-fge-json-schema-validation-00#section-6.2)されています。ざっくり言うと「補足情報」でありvalidation上は意味を成さないという意味です。

うん、あまり深く考えなくて良いです！

### Schemaの例

基本的には公式の[examples](http://json-schema.org/examples.html)を斜め読みすれば必要そうな概念は十分に理解出来ます。
それを読み終えたら[JSON Schema Test Suite](https://github.com/json-schema/JSON-Schema-Test-Suite)を見ると、各keywordがどういう意味なのか理解出来ると思います。
ちなみにJSVモジュールは現時点でTest Suiteは全て通ってる感じです。

#### Test Suite 解説

[multipleOfキーワードのTest Suite](https://github.com/json-schema/JSON-Schema-Test-Suite/blob/develop/tests/draft4/multipleOf.json)を例にちょっとだけ解説してみます。

#### JSON-RPC 2.0 Request の例

また、例えば[JSON-RPC 2.0](http://www.jsonrpc.org/specification)の[Request形式](http://www.jsonrpc.org/specification#request_object)をもしSchemaにするんだとするとこんな感じになります。

書いてある事をざっくり日本語にすると以下のようになります。

| field | description |
|:-----:|:------------|
| jsonrpc | JSON-RPCプロトコルバージョンを表す文字列で"2.0"でなければならない |
| method | 呼び出したいメソッド名を表す文字列。"rpc."から始まる奴は予約メソッド。 |
| params | 構造化データ(array または object)。省略可能。 |
| id | nullまたは文字列、数値 |

この仕様の文章だけ読むと曖昧さが残るのですが、強いてスキーマにすると次のような感じです。

```javascript
{
  "title": "JSON-RPC 2.0 Request Object Schema",
  "type": "object",
  "properties": {
    "jsonrpc": {
      "enum": ["2.0"]
    },
    "method": {
      "type": "string",
      "minLength": 1
    },
    "params": {
      "oneOf": [
        { "type": "array" },
        { "type": "object" }
      ],
      "default": []
    },
    "id": {
      "oneOf": [
        { "type": "null" },
        { "type": "string" },
        { "type": "number" }
      ],
      "default": null
    }
  },
  "required": ["jsonrpc", "method"]
}
```

大体こんな感じになります。
