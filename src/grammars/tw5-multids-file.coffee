grammar =
  name: "TiddlyWiki5 multids file"
  scopeName: "source.tw5.multids-file"
  fileTypes: [
    "multids"
  ]
  patterns: [
    {
      comment: "Tokenize tiddler title and text pairs."
      begin: "(?<=^$)"
      end: "(?=1)0"
      contentName: "meta.dictionary.tiddler-fields.title-text-pairs.tw5.multids-file"
      patterns: [
        {
          include: "#comment"
        }
        {
          include: "#titleAndTextPair"
        }
      ]
    }
    {
      comment: "Tokenize common tiddler metadata."
      begin: "^"
      end: "^$"
      name: "meta.dictionary.tiddler-fields.tw5.multids-file"
      patterns: [
        {
          include: "source.tw5.dictionary"
        }
      ]
    }
  ]
  repository:
    comment:
      match: "^(#).*$"
      name: "comment.line.number-sign.tw5.multids-file"
      captures:
        1:
          name: "punctuation.definition.comment.tw5.multids-file"
    titleAndTextPair:
      match: "^(.*?)(: )(.*)"
      name: "meta.value-pair.title-text.tw5.multids-file"
      captures:
        1:
          name: "string.other.field.title.value.tw5.multids-file"
        2:
          name: "punctuation.separator.key-value.title-text.tw5.multids-file"
        3:
          patterns: [
            {
              begin: "^"
              end: "$"
              name: "meta.tiddler-field.text.tw5.multids-file"
              contentName: "text.html.tw5.multids-file"
              patterns: [
                {
                  include: "text.html.tw5"
                }
              ]
            }
          ]


module.exports = grammar
