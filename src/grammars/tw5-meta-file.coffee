grammar =
  name: "TiddlyWiki5 meta file"
  scopeName: "source.tw5.meta-file"
  fileTypes: [
    "meta"
  ]
  patterns: [
    {
      begin: "^"
      end: "(?=1)0"
      contentName: "meta.dictionary.tiddler-fields.tw5.meta-file"
      patterns: [
        {
          include: "source.tw5.dictionary"
        }
      ]
    }
  ]

module.exports = grammar
