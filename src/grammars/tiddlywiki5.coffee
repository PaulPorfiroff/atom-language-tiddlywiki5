grammar =
  name: "TiddlyWiki5"
  comment: "Grammar for TiddlyWiki5 tiddler fields description files"
  scopeName: "text.html.tw5"
  fileTypes: [
    "tid"
  ]
  patterns: [
    {
      include: "#wikitext"
    }
  ]
  repository:
    wikitext:
      patterns: [
        {
          include: "text.html.basic"
        }
      ]

module.exports = grammar
