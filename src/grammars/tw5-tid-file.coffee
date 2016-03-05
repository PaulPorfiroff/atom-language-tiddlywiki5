grammar =
  name: "TiddlyWiki5 tid file"
  scopeName: "source.tw5.tid-file"
  fileTypes: [
    "tid"
  ]
  patterns: [
    {
      # @HACK:
      # Omit the `type` tiddler field value and consider the `text` to be TW5
      # wikitext.
      comment: "Tokenize tiddler text field."
      begin: "(?<=^$)"
      end: "(?=1)0" # Continue matching rule until EOF is met
      name: "meta.tiddler-field.text.tw5.tid-file"
      contentName: "text.html.tw5.tid-file"
      patterns: [
        {
          include: "text.html.tw5"
        }
      ]
    }
    {
      comment: "Tokenize mandatory tiddler metadata."
      begin: "^"
      end: "^$"
      name: "meta.dictionary.tiddler-fields.tw5.tid-file"
      patterns: [
        {
          include: "source.tw5.dictionary"
        }
      ]
    }
  ]

module.exports = grammar
