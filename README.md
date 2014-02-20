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

また、例えば[JSON-RPC 2.0](http://www.jsonrpc.org/specification)の[Request形式](http://www.jsonrpc.org/specification#request_object)を題材にしてみます。

```
POST /jsonrpc HTTP/1.1
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "method": "system.listMethods",
  "id": "tehepero"
}
```

みたいな奴です。

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
慣れてくると大概のデータ表現に対して必要十分なスキーマを書けるようになります。

## Extending JSON Schema

ここまでは凄い簡単な例でしたが、より高度なスキーマを書きたい！ってなった時に避けて通れない概念があります。

 * [JSON Pointer (RFC 6901)](http://tools.ietf.org/html/rfc6901)
 * [JSON Reference](http://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03)
 * [allOf](http://tools.ietf.org/html/draft-fge-json-schema-validation-00#section-5.5.3), [anyOf](http://tools.ietf.org/html/draft-fge-json-schema-validation-00#section-5.5.4), [oneOf](http://tools.ietf.org/html/draft-fge-json-schema-validation-00#section-5.5.5), [not](http://tools.ietf.org/html/draft-fge-json-schema-validation-00#section-5.5.6)keyword

### JSON Pointer

Mojoliciousユーザーはもしかしたらご存知かもしれませんが、JSONドキュメント中の任意の値を指し示す為のポインタ表現です。RFC 6901として仕様化されています。
Perl実装はMojolicious内にもありますが、[JSON::Pointer](https://metacpan.org/pod/JSON::Pointer)モジュールがシンプルで便利です（ぉ

SYNOPSISコピペしておきますね！

```perl
use JSON::Pointer;
 
my $obj = {
  foo => 1,
  bar => [ { qux => "hello" }, 3 ],
  baz => { boo => [ 1, 3, 5, 7 ] }
};
 
JSON::Pointer->get($obj, "/foo");       ### $obj->{foo}
JSON::Pointer->get($obj, "/bar/0");     ### $obj->{bar}[0]
JSON::Pointer->get($obj, "/bar/0/qux"); ### $obj->{bar}[0]{qux}
JSON::Pointer->get($obj, "/bar/1");     ### $obj->{bar}[1]
JSON::Pointer->get($obj, "/baz/boo/2"); ### $obj->{baz}{boo}[2]
```

### JSON Reference

[JSON Reference](http://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03)とは、こんな奴です。

```javascript
{ "$ref": "http://example.com/example.json#/foo/bar" }
```

これはどういう意味かと言うと、次のように解釈して下さい。

* http://example.com/example.json にある JSON 文書の
* /foo/bar で示される JSON object で
* $ref がある Object の中身を丸っと置き換える

example.json の中身が以下のようになってるとしましょう。

```javascript
{
  "foo": {
    "bar": {
      "type": "array",
      "items": { "enum": ["begin", "commit", "rollback"] },
      "uniqueItems": true,
      "minItems": 1
    }
  }
}
```

この時、先ほどの $ref を用いた JSON は次のようにresolutionされます。

```javascript
{
  "type": "array",
  "items": { "enum": ["begin", "commit", "rollback"] },
  "uniqueItems": true,
  "minItems": 1
}
```

JSON Referenceは(絶対及び相対)URIとfragmentで示されるJSON Pointerによって、外部のJSONをinclude出来る概念です。
ちなみにURIを省略する場合は文書内を指し示します。良くある例としては、

```javascript
{
  "definitions": {
    "Person": { "$ref": "http://example.com/person.json" },
    "PersonCollection": {
      "type": "array",
      "items": { "$ref": "#/definitions/Person" }
    }
  }
}
```

みたいな使い方をします。

### allOf, anyOf, oneOf, not キーワード

ちょっと前にoneOfキーワードが出てきましたが、前に作ってみたJSON-RPC 2.0 Requestのスキーマを「再利用」して現実的なJSON-RPC 2.0のメソッドに対してバリデーションを行うようなスキーマを書いてみます。
しばしばJSON-RPC 2.0にも[XML-RPC Introspecction](http://xmlrpc-c.sourceforge.net/introspection.html)で定義されるメソッド群が実装される事がありますが、そのうちsystem.methodHelpについて表現してみましょう。このメソッドを指定したRPCメソッド名に対してヘルプメッセージを返すAPIです。

仮に先ほどのJSON-RPC 2.0 Requestのスキーマが http://example.com/jsonrpc/request.json で定義されているとします。
新たに付け加えるべきvalidationルールとしては以下になります。

* method名はsystem.methodHelpであること
* 引数はarray形式で1つのみ受け取り、それはメソッド名である事

です。リクエストのサンプルとしては例えば次のようになります。

```
POST /jsonrpc HTTP/1.1
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "method": "system.methodHelp",
  "params": ["system.listMethods"],
  "id": "hidek"
}
```

さて、実際に書き起こしてみましょう。

```javascript
{
  "id": "http://example.com/jsonrpc/methods/system.listMethods.json",
  "title": "system.listMethods request schema",
  "allOf": [
    { "$ref": "http://example.com/jsonrpc/request.json" },
    {
      "properties": {
        "method": { "enum": ["system.listMethods"] },
        "params": { 
          "type": "array",
          "items": [
            { "$ref": "http://example.com/jsonrpc/request.json#/properties/method" }
          ],
          "minItems": 1,
          "additionalItems": false
        }
      },
      "required": ["method", "params"]
    }
  ]
}
```

理解出来ますかね？あるいは次のようにも書く事が出来ると思います。

```javascript
{
  "id": "http://example.com/jsonrpc/methods/system.listMethods.json",
  "title": "system.listMethods request schema",
  "oneOf": [
    { "$ref": "http://example.com/jsonrpc/request.json" }
  ]
  "properties": {
    "method": { "enum": ["system.listMethods"] },
    "params": { 
      "type": "array",
      "items": [
        { "$ref": "http://example.com/jsonrpc/request.json#/properties/method" }
      ],
      "minItems": 1,
      "additionalItems": false
    }
  },
  "required": ["method", "params"]
}
```

allOf, anyOf, oneOf, not は次のようなkeywordです。

* allOf
  * 指定された複数のスキーマ全てに対してvalidであればvalid
* anyOf
  * 指定された複数のスキーマのうち少なくとも1つvalidであればvalid
* oneOf
  * 指定された複数のスキーマのうち1個のみvalidであればvalid
* not
  * 指定されたスキーマに対してinvalidであればvalid

これらの概念を駆使するとSchemaの再利用と拡張を書く事が出来ます。ここまで使いこなせればJSON Schema免許皆伝です。

## JSVモジュールの説明

仕様の説明はきりがないので肝心のモジュールについて説明しますよ。主要なモジュールは以下になります。

* JSV::Validator
  * validationを行うにはこのモジュールのインスタンスが必要
* JSV::Reference
  * スキーマデータの格納庫。再利用する際に間接的にお世話になる
* JSV::Context
  * validation中の状態管理用。内部でしか使ってないけど凄い重要な人
* JSV::Result
  * validation結果です。どこでエラーになったよとかの情報を持ってる。リリース出来てない理由の一つはResultをもっと便利にしたいのだがまだ実装出来てないのでした。

## まとめ

眠い。。。
