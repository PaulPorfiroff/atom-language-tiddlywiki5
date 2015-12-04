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
          include: "#horizrule"
        }
        {
          include: "text.html.basic"
        }
      ]
    horizrule:
      match: "^\\s*-{3,}$"
      name: "meta.separator.hr.tw5"

module.exports = grammar
