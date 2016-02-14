# @NOTE:
# From `$tw.utils.parseFields()`
grammar =
  name: "TiddlyWiki5 dictionary"
  scopeName: "source.tw5.dictionary"
  patterns: [
    {
      include: "#dictionary"
    }
  ]
  repository:
    dictionary:
      patterns: [
        {
          include: "#comment"
        }
        {
          include: "#field"
        }
      ]

    comment:
      match: "^(#).*$"
      name: "comment.line.number-sign.tw5.dictionary"
      captures:
        1:
          name: "punctuation.definition.comment.tw5.dictionary"
    field:
      # @TODO:
      # Tokenize predefined tiddler fields explicitly.
      patterns: [
        {
          match: "^\\s*([^:]+?)??\\s*(:)\\s*(.+?)??\\s*$"
          name: "meta.value-pair.tiddler-field.tw5.dictionary"
          captures:
            1:
              name: "entity.other.tiddler-field.tw5.dictionary"
            2:
              name: "punctuation.separator.key-value.tiddler-field.tw5.dictionary"
            3:
              name: "string.other.field.value.tw5.dictionary"
        }
      ]

module.exports = grammar
