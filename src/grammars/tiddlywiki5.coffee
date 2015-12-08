classesRegex = "(?:\\.(?:[^\\s\\.]+))+"

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
          include: "#pragma"
        }
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
    pragma:
      patterns: [
        {
          include: "#rules"
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
        {
          include: "#hardlinebreaks"
        }
      ]
    block:
      patterns: [
        {
          include: "#codeblock"
        }
        {
          include: "#typedblock"
        }
        {
          include: "#heading"
        }
        {
          include: "#horizrule"
        }
      ]

    rules:
      match: "^(\\\\)(rules)\\s+(only|except)?(.*)$"
      name: "meta.pragma.rules.comment.tw5"
      captures:
        1:
          name: "punctuation.definition.pragma.tw5"
        2:
          name: "keyword.other.rules.tw5"
        3:
          name: "keyword.other.$3.tw5"
        4:
          patterns: [
            {
              match: "\\S+"
              name: "variable.parameter.tw5"
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
    hardlinebreaks:
      begin: "\"\"\""
      end: "\\0"
      contentName: "markup.other.paragraph.tw5"
      beginCaptures:
        0:
          name: "punctuation.definition.paragraph.markup.begin.tw5"
      endCaptures:
        0:
          name: "punctuation.definition.paragraph.markup.end.tw5"
      patterns: [
        {
          include: "#inline"
        }
      ]

    codeblock:
      begin: "^\\s*(```)(?=[\\w-]*$)"
      end: "^(```)$"
      name: "meta.codeblock.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.raw.markup.begin.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.raw.markup.end.tw5"
      patterns: [
        {
          begin: "(?i)\\G(#{language})$"
          end: "(?=^```$)"
          contentName: "#{scope}.tw5"
          beginCaptures:
            1:
              name: "entity.other.attribute-name"
          patterns: [
            {
              include: scope
            }
          ]
        } for language, scope of {
          "m(?:arkdown|d|kd(?:own)?)": "source.gfm"
          "gemspec|irb|podspec|r(?:b|uby)|thor": "source.ruby"
          "m(?:ak(?:efile)?|k)": "source.makefile"
          "json": "source.json"
          "atom|rss|xhtml": "text.xml"
          "xsl": "text.xml.xsl"
          "html": "text.html.basic"
          "plist": "text.xml.plist"
          "css": "source.css"
          "p(?:erl|l)": "source.perl"
          "cs(?:harp)?": "source.cs"
          "obj(?:\\-c|c|ectivec)": "source.objc"
          "mm": "source.objcpp"
          "gyp|py(?:thon)?": "source.python"
          "java": "source.java"
          "jsp": "text.html.jsp"
          "bash|sh|zsh": "source.shell"
          "sql": "source.sql"
          "c|p": "source.c"
          "c(?:\\+\\+|c|pp)|h(?:\\+\\+|pp)": "source.cpp"
          "php(?:3|4|5|6)?": "text.html.php"
          "ini|toml": "source.toml"
          "diff|patch": "text.git-commit"
          "c(?:offee(?:script)?|son)|iced": "source.coffee"
          "j(?:avascript|s)": "source.js"
        }...
        {
          begin: "\\G[\\w-]*$"
          end: "(?=^```$)"
          contentName: "markup.raw.tw5"
    typedblock:
      begin: "^\\s*(\\$\\$\\$)(?=[^\\s>]*(?:\\s*>\\s*\\S+)?$)"
      end: "^(\\$\\$\\$)$"
      name: "meta.typedblock.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.typedblock.begin.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.typedblock.end.tw5"
      patterns: [
        {
          begin: "\\G(#{parseType})(?:\\s*(>)\\s*(\\S+))?$"
          end: "(?=^\\$\\$\\$$)"
          contentName: "#{scope}.tw5"
          beginCaptures:
            1:
              name: "entity.other.attribute-name.parse.tw5"
            2:
              name: "punctuation.definition.typedblock.render.tw5"
            3:
              name: "entity.other.attribute-name.render.tw5"
          patterns: [
            {
              include: scope
            }
          ]
        } for parseType, scope of {
          "\\.tid|application\\/x\\-tiddler": "#wikitext"
          "\\.css|text\\/css": "source.css"
          "\\.html?|text\\/html": "text.html.basic"
          "\\.hta|application\\/hta": "text.html.basic"
          "\\.js|application\\/javascript": "source.js"
          "\\.json|application\\/json": "source.json"
          "\\.svg|image\\/svg\\+xml": "text.xml"
          "\\.m(?:arkdown|d)|text\\/x\\-markdown": "source.gfm"
        }...
        {
          begin: "\\G([^\\s>]*)(?:\\s*(>)\\s*(\\S+))?$"
          end: "(?=^\\$\\$\\$$)"
          contentName: "markup.raw.tw5"
          beginCaptures:
            1:
              name: "entity.other.attribute-name.parse.tw5"
            2:
              name: "punctuation.definition.typedblock.render.tw5"
            3:
              name: "entity.other.attribute-name.render.tw5"
        }
      ]
    heading:
      patterns: [
        {
          begin: "^\\s*(!{#{i}})(#{classesRegex})?\\s*"
          end: "$"
          name: "markup.heading.#{i}.tw5"
          beginCaptures:
            1:
              name: "punctuation.definition.heading.markup.tw5"
            2:
              patterns: [
                {
                  include: "#classes"
                }
              ]
          patterns: [
            {
              include: "#inline"
            }
          ]
        } for i in [6..1]...
      ]
    horizrule:
      match: "^\\s*-{3,}$"
      name: "meta.separator.hr.tw5"

    # From WikiParser::parseClasses()
    classes:
      match: classesRegex
      name: "meta.support.classes.tw5"
      captures:
        0:
          patterns: [
            {
              match: "(\\.([^\\s\\.]+))"
              captures:
                1:
                  name: "entity.other.attribute-name.class.css"
                2:
                  name: "punctuation.definition.entity.css"
            }
          ]

module.exports = grammar
