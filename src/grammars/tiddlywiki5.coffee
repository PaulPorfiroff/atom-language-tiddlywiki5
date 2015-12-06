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
          include: "#block"
        }
        {
          include: "#inline"
        }
        {
          include: "text.html.basic"
        }
      ]
    inline:
      patterns: [
        {
          include: "#emphasis"
        }
        {
          include: "#codeinline"
        }
      ]
    block:
      patterns: [
        {
          include: "#horizrule"
        }
      ]

    emphasis:
      patterns:
        {
          begin: mark
          end: mark
          contentName: "#{name}.markup.tw5"
          beginCaptures:
            0:
              name: "#{name}.punctuation.definition.markup.begin.tw5"
          endCaptures:
            0:
              name: "#{name}.punctuation.definition.markup.end.tw5"
          patterns: [
            {
              include: "#inline"
            }
          ]
        } for mark, name of {
          "''": "bold"
          "//": "italic"
          "__": "underscore"
          "\\^\\^": "superscript"
          ",,": "subscript"
          "~~": "strikethrough"
        }
    codeinline:
      begin: "``?"
      end: "\\0"
      contentName: "markup.raw.tw5"
      beginCaptures:
        0:
          name: "punctuation.definition.raw.markup.begin.tw5"
      endCaptures:
        0:
          name: "punctuation.definition.raw.markup.end.tw5"

    horizrule:
      match: "^\\s*-{3,}$"
      name: "meta.separator.hr.tw5"

module.exports = grammar
