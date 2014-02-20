# Introduction JSON Schema and perl-JSV

* Toru Yamaguchi <zigorou at cpan dot org>
* Yokohama.pm #10
* 2014/02/21

最初、Keynoteで書き始めたけど体裁気にして書くのが面倒なのでMarkdownにて失敬！

## Introduction JSON Schema

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
