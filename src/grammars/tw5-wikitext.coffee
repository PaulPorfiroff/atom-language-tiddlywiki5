regexes = new ->
  @classes = "(?:\\.[^\\s\\.]+)+"
  @styles = "(?:[^\\s]+?\\:.+?;)+"
  @schemes = "file|http|https|mailto|ftp|irc|news|data|skype"

  # From $:/core/modules/config.js
  @lowerLetter = "[a-zß-öø-ÿőű]"
  @upperLetter = "[A-ZÀ-ÖØ-ÞŐŰ]"
  @anyLetter = "(?:#{@lowerLetter})|(?:#{@upperLetter})"
  @blockPrefixLetters = "(?:#{@anyLetter})|\\-|_"
  @unWikiLink = "~"
  @wikiLink = "(?:#{@upperLetter})+(?:#{@lowerLetter})+(?:#{@upperLetter})(?:#{@anyLetter})*"

# @NOTE:
# WikiParser::parseBlock() defaults to paragraph node, if no block rule matches
# at current position.
makeFallbackBlockRule = (endRegEx) ->
  begin: "^(?!\\s*$)"
  end: if endRegEx then "(?:#{endRegEx})|^$" else "^$"
  name: "markup.other.paragraph.tw5"
  patterns: [
    {
      include: "#inline"
    }
  ]

grammar =
  name: "TiddlyWiki5"
  scopeName: "text.html.tw5"
  patterns: [
    {
      include: "#wikitext"
    }
  ]
  injections:
    "meta.function.macro.body.tw5":
      patterns: [
        {
          # From `Widget::substituteVariableReferences()`
          comment: "Parse variable reference."
          match: "(\\$\\()(.+?)(\\)\\$)"
          name: "markup.other.variable.variable-reference.tw5"
          captures:
            1:
              name: "punctuation.definition.variable.variable-reference.begin.tw5"
            2:
              name: "entity.other.name.variable.tw5"
            3:
              name: "punctuation.definition.variable.variable-reference.end.tw5"
        }
        {
          # From `Widget::substituteVariableParameters()`
          comment: "Parse variable parameter."
          match: "(\\$)(.*?)(\\$)"
          name: "markup.other.variable.variable-parameter.tw5"
          captures:
            1:
              name: "punctuation.definition.variable.variable-parameter.begin.tw5"
            2:
              name: "variable.parameter.tw5"
            3:
              name: "punctuation.definition.variable.variable-parameter.end.tw5"
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
        makeFallbackBlockRule()
        {
          include: "text.html.basic"
        }
      ]

#
# Section: Wiki text pragma rules
#

    pragma:
      patterns: [
        {
          include: "#macrodef"
        }
        {
          include: "#rules"
        }
      ]

    macrodef:
      # @HACK:
      # Expect macro name to be on the same line, as pragma definition start.
      # @HACK:
      # In `WikiParser`'s `macrodef` rule macro body is considered empty, if no
      # end pattern was found. However, cannot do multiline lookahead with
      # PEG rules here.
      # So, there's an ambiguity between empty and multiline macro bodies, which
      # is ignored.
      begin: "^(\\\\)(define)\\s+([^\\s\\(]+)(?=\\()"
      end: "^"
      name: "meta.pragma.directive.function.macro.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.pragma.directive.tw5"
        2:
          name: "keyword.control.directive.define.tw5"
        3:
          name: "entity.name.function.macro.tw5"
      patterns: [
        {
          comment: "Match single line macro body."
          match: "(?<=\\))\\s*(\\S.*)$"
          captures:
            1:
              # @NOTE:
              # This way injections will work.
              begin: "^"
              end: "$"
              name: "meta.function.macro.body.tw5"
              patterns: [
                {
                  include: "#wikitext"
                }
              ]
        }
        {
          comment: "Match multiline macro body."
          begin: "(?<=\\))\\s*$"
          end: "(\\\\)(end)\\s*?$"
          contentName: "meta.function.macro.body.tw5"
          endCaptures:
            1:
              name: "punctuation.definition.pragma.directive.tw5"
            2:
              name: "keyword.control.directive.end.tw5"
          patterns: [
            {
              include: "#block"
            }
            makeFallbackBlockRule("(?=\\\\end\\s*?$)")
          ]
        }
        {
          comment: "Parse parameter list."
          begin: "(?<=\\S)\\("
          end: "\\)"
          name: "meta.function.macro.parameters.tw5"
          beginCaptures:
            0:
              name: "punctuation.definition.function.macro.parameters.begin.tw5"
          endCaptures:
            0:
              name: "punctuation.definition.function.macro.parameters.end.tw5"
          patterns: [
            # @HACK:
            # Assume parameter name and default value are on the same line.
            {
              # Match parameter with default value expressed by a quoted string.
              begin: "([\\w\\-]+)(?:\\s*(:)\\s*(?=#{begin}))"
              end: "(?<=#{end})"
              name: "meta.function.macro.parameter.tw5"
              contentName: "entity.other.default.value.tw5"
              beginCaptures:
                1:
                  name: "variable.parameter.tw5"
                2:
                  name: "keyword.operator.assignment.tw5"
              patterns: [
                {
                  include: "#string"
                }
              ]
            } for [begin, end] in [
              ["\"\"\"", "\"\"\""]
              ["\"", "\""]
              ["\'", "\'"]
              ["\\[\\[", "\\]\\]"]
            ]...
            {
              # Match parameter with default value expressed by an unquoted
              # string.
              match: "([\\w\\-]+)(?:\\s*(:)\\s*([^\\)\"\'\\s]+))"
              name: "meta.function.macro.parameter.tw5"
              captures:
                1:
                  name: "variable.parameter.tw5"
                2:
                  name: "keyword.operator.assignment.tw5"
                3:
                  begin: "^"
                  end: "$"
                  name: "entity.other.default.value.tw5"
                  patterns: [
                    {
                      include: "#string"
                    }
                  ]
            }
            {
              comment: "Parse formal argument definition."
              match: "[\\w\\-]+"
              name: "meta.function.macro.parameter.tw5"
              captures:
                0:
                  name: "variable.parameter.tw5"
            }
            {
              comment: "Match parameter separators."
              match: "[^\\w\\-\\)\\s]+"
              name: "punctuation.separator.function.macro.parameter.tw5"
            }
          ]
        }
      ]
    rules:
      match: "^(\\\\)(rules)\\s+(only|except)?(.*)$"
      name: "meta.pragma.directive.rules.tw5"
      captures:
        1:
          name: "punctuation.definition.pragma.directive.tw5"
        2:
          name: "keyword.control.directive.rules.tw5"
        3:
          name: "keyword.operator.$3.tw5"
        4:
          patterns: [
            {
              match: "\\S+"
              name: "variable.parameter.tw5"
            }
          ]

#
# Section: Wiki text block rules
#

    block:
      patterns: [
        {
          include: "#codeblock"
        }
        {
          include: "#typedblock"
        }
        {
          include: "#styleblock"
        }
        {
          include: "#quoteblock"
        }
        {
          include: "#macrocallblock"
        }
        {
          include: "#filteredtranscludeblock"
        }
        {
          include: "#transcludeblock"
        }
        {
          include: "#table"
        }
        {
          include: "#list"
        }
        {
          include: "#heading"
        }
        {
          include: "#horizrule"
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
              name: "entity.other.attribute-name.language.tw5"
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
          begin: "\\G([\\w-]*)$"
          end: "(?=^```$)"
          contentName: "markup.raw.tw5"
          beginCaptures:
            1:
              name: "entity.other.attribute-name.language.tw5"
        }
      ]
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
          "\\.tid|application\\/x\\-tiddler": "text.html.tw5"
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
    styleblock:
      applyEndPatternLast: 1
      # @NOTE:
      # The only difference between `styleinline` and `styleblock` detectors is
      # mandatory EOL for the latter, so can't reduce the `begin` regex.
      begin: "^\\s*(?=@@(#{regexes.styles})?(#{regexes.classes})?$)"
      end: "(?<=^@@)\\s*(.*)$"
      contentName: "markup.other.style.styleblock.tw5"
      endCaptures:
        # @HACK:
        # __Problem__:
        # TW5's `styleblock` rule end detector allows writing new block
        # definitions starting on the same line, where the end marker is. Currently
        # this breaks `block` rule detectors in this grammar.
        #
        # __Solution__:
        # As this behaviour is inconsistent with other block rules and likely
        # to be not desired, just drop it for now and provide some feedback.
        # Welp, or just modify block rules up.
        1:
          name: "invalid.illegal.tw5"
      patterns: [
        {
          comment: "Tokenize markers, styles and classes."
          match: "(?:^|\\G)(@@)(#{regexes.styles})?(#{regexes.classes})?\\r?\\n"
          name: "meta.styleblock.definition.begin.top.tw5"
          captures:
            1:
              name: "punctuation.definition.markup.other.style.styleblock.begin.tw5"
            2:
              patterns: [
                {
                  include: "#styles"
                }
              ]
            3:
              patterns: [
                {
                  include: "#classes"
                }
              ]
        }
        {
          comment: "Tokenize body and end marker."
          begin: "^"
          end: "^(@@)"
          contentName: "meta.styleblock.definition.body.tw5"
          endCaptures:
            0:
              name: "meta.styleblock.definition.end.bottom.tw5"
            1:
              name: "punctuation.definition.markup.other.style.styleblock.end.tw5"
          patterns: [
            {
              include: "#block"
            }
            makeFallbackBlockRule("^(?=@@)")
          ]
        }
      ]
    quoteblock:
      # @HACK:
      # __Goals__:
      # * Allow using 1 EOL for paragraphs at the end of `quoteblock`.
      # * Allow using __multiline__ inline elements in cites (like """...""").
      #
      # __Problem__:
      # New nesting level of the `quoteblock` begins with marker matching `<<<+`
      # pattern. For the goals above need nested `patterns`/additional rules.
      # Nested rules cannot back reference captured groups from parent rule, so
      # no way to detect the exact matched begin/end marker of `quoteblock`
      # definition (which is only known at parse time).
      #
      # __Solution__:
      # Using a set of predefined begin markers and splitting into multiple
      # rules seems to be an acceptable workaround.
      patterns: [
        {
          applyEndPatternLast: 1
          # If empty top cite given, eat EOL to go to new line and skip top cite
          # rule.
          begin: "^\\s*(#{detector})(?!<)(?:\\r?\\n)?"
          end: "$"
          name: "markup.quote.blockquote.tw5"
          beginCaptures:
            1:
              name: "punctuation.definition.markup.quote.blockquote.begin.tw5"
          patterns: [
            {
              comment: "Tokenize classes and top cite."
              # Don't let top cite detector match after empty bottom cite rule
              # has matched. Explicitly check for no EOL ahead.
              begin: "(?<=#{detector})(?!$)(#{regexes.classes})?[^\\S\\n]*"
              end: "\\r?\\n"
              contentName: "meta.quote.blockquote.cite.top.tw5"
              beginCaptures:
                1:
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
            }
            {
              comment: "Tokenize bottom cite."
              begin: "^(#{detector})(?!<)[^\\S\\n]*?"
              end: "$"
              contentName: "meta.quote.blockquote.cite.bottom.tw5"
              beginCaptures:
                1:
                  name: "punctuation.definition.markup.quote.blockquote.end.tw5"
              patterns: [
                {
                  include: "#inline"
                }
              ]
            }
            {
              comment: "Tokenize body."
              begin: "^"
              end: "^(?=#{detector}(?!<))"
              patterns: [
                {
                  include: "#block"
                }
                makeFallbackBlockRule("^(?=#{detector}(?!<))")
              ]
            }
          ]
        } for detector in ["<<<<<", "<<<<", "<<<"]...
      ]
    macrocallblock:
      begin: "^\\s*(<<)([^>\\s]+)"
      end: "(>>)\\r?\\n"
      name: "meta.function-call.macrocallblock.tw5"
      contentName: "meta.function.macro.parameters.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.macrocallblock.begin.tw5"
        2:
          name: "entity.name.function.macro.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.macrocallblock.end.tw5"
      patterns: [
        # @HACK:
        # Assume parameter name and value are on the same line.
        {
          # Match positional or named assignment of value, expressed by a quoted
          # string.
          #
          # @FIXME:
          # For some reason fails to stop eating strings in constructs like
          # these:
          #
          # ```
          # <<myMacro 'value1''value2'>>
          # <<myMacro "value1""value2">>
          # ```
          begin: "(?:([\\w\\-]+)\\s*(:)\\s*)?(?=#{begin})"
          end: "(?<=#{end})"
          name: "meta.function.macro.parameter.tw5"
          beginCaptures:
            1:
              name: "variable.parameter.tw5"
            2:
              name: "keyword.operator.assignment.tw5"
          patterns: [
            {
              include: "#string"
            }
          ]
        } for [begin, end] in [
          ["\"\"\"", "\"\"\""]
          ["\"", "\""]
          ["\'", "\'"]
          ["\\[\\[", "\\]\\]"]
        ]...
        {
          # Match positional or named assignment of value, expressed by an
          # unquoted string.
          match: "(?:([\\w\\-]+)\\s*(:)\\s*)?([^\\>\"\'\\s]+)"
          name: "meta.function.macro.parameter.tw5"
          captures:
            1:
              name: "variable.parameter.tw5"
            2:
              name: "keyword.operator.assignment.tw5"
            3:
              begin: "^"
              end: "$"
              patterns: [
                {
                  include: "#string"
                }
              ]
        }
        {
          comment: "Match separators."
          match: "[^\\w\\-\\>\\s]+"
          name: "punctuation.separator.function.macro.parameter.tw5"
        }
      ]
    filteredtranscludeblock:
      # @HACK:
      # For now drop detection of `tooltip`, `style` and `itemClass` parts of
      # the rule, because the underlying `ListWidget` widget ignores them.
      begin: "^\\s*(\\{\\{\\{)"
      end: "(\\}\\}\\})\\r?\\n"
      name: "meta.transclusion.filteredtranscludeblock.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.transclusion.filteredtranscludeblock.begin.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.transclusion.filteredtranscludeblock.end.tw5"
      patterns: [
        {
          comment: "Tokenize template tiddler title."
          begin: "(\\|\\|)"
          end: "(?=\\}\\}\\})"
          beginCaptures:
            1:
              name: "punctuation.definition.transclusion.filteredtranscludeblock.template.tw5"
          patterns: [
            {
              comment: "Treat nearest non-whitespace line as template tiddler title."
              begin: "(?<=\\|\\|)\\G"
              end: "(?=\\S)((?:(?!\\}\\}\\}).)*?)\\s*(?=$|\\}\\}\\})"
              endCaptures:
                1:
                  name: "entity.other.name.tiddler.title.template.tw5"
            }
            {
              # If another non-whitespace character occurs below, start marking
              # things illegal.
              begin: "(?=\\S)"
              end: "(?=\\}\\}\\})"
              name: "invalid.illegal.multiline-tiddler-title.tw5"
            }
          ]
        }
        # Tokenize filter string.
        # makeFilterRule("(?=\\|\\||\\}\\}\\})")
        {
          begin: "\\G"
          end: "(?=\\|\\||\\}\\}\\})"
          name: "meta.filter.tw5"
          patterns: [
            {
              include: "#filter"
            }
          ]
        }
      ]
    transcludeblock:
      # @HACK:
      # * No fallback to paragraph when illegal characters met.
      # * No illegal character feedback.
      # @NOTE:
      # Only first non-empty lines of text reference and template title
      # are used. Whitespaces get trimmed, as in TW5 rule. Other lines are
      # marked illegal.
      begin: "^\\s*(\\{\\{)"
      end: "(\\}\\})\\r?\\n"
      name: "meta.transclusion.transcludeblock.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.transclusion.transcludeblock.begin.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.transclusion.transcludeblock.end.tw5"
      patterns: [
        {
          comment: "Tokenize template tiddler title."
          begin: "(\\|\\|)"
          end: "(?=\\}\\})"
          beginCaptures:
            1:
              name: "punctuation.definition.transclusion.transcludeblock.template.tw5"
          patterns: [
            {
              # Let a trimmed portion of the nearest line containing
              # non-whitespace char be a template tiddler title.
              comment: "Treat nearest non-whitespace line as template tiddler title."
              begin: "(?<=\\|\\|)\\G"
              end: "(?=\\S)((?:(?!\\}\\}).)*?)\\s*(?=$|\\}\\})"
              endCaptures:
                1:
                  name: "entity.other.name.tiddler.title.template.tw5"
            }
            {
              # If another non-whitespace character occurs below, start marking
              # things illegal.
              begin: "(?=\\S)"
              end: "(?=\\}\\})"
              name: "invalid.illegal.multiline-tiddler-title.tw5"
            }
          ]
        }
        {
          comment: "Tokenize text reference."
          begin: "(?<=\\{\\{)\\G"
          end: "(?=\\}\\}|\\|\\|)"
          patterns: [
            {
              # Detect and eat non-empty portion of the first line of text
              # reference if present.
              begin: "(?<=\\{\\{)\\G"
              end: """(?x)
              (?= \\}\\} | \\|\\|) | # Allow dropping text reference
              (\\S.*?)\\s* (?= $ | \\}\\} | \\|\\|)
              """
              endCaptures:
                1:
                  patterns: [
                    {
                      include: "#textReference"
                    }
                  ]
            }
            {
              # If another non-whitespace character occurs below, start marking
              # things illegal.
              begin: "(?=\\S)"
              end: "(?=\\|\\||\\}\\})"
              name: "invalid.illegal.multiline-text-reference.tw5"
            }
          ]
        }
      ]

    table:
      patterns: [
        {
          match: "^(\\|)(.*)(\\|)(#{marker})$"
          name: "markup.other.table.tw5"
          captures:
            0:
              name: "#{scope}.meta.table.tw5"
            1:
              name: "punctuation.definition.table.pipe.outer.begin.tw5"
            2: rule
            3:
              name: "punctuation.definition.table.pipe.outer.end.tw5"
            4:
              name: "#{scope}.markup.other.table.tw5"
        } for marker, {scope, rule} of {
          # Tokenize table classes.
          "k":
            scope: "classes"
            rule:
              patterns: [
                {
                  match: "^.*$"
                  name: "meta.support.classes.tw5"
                  captures:
                    0:
                      name: "entity.other.attribute-name.class.css"
                }
              ]
          # Tokenize table caption.
          "c":
            scope: "caption"
            rule:
              patterns: [
                {
                  match: "^.*$"
                  name: "entity.other.name.caption.tw5"
                  captures:
                    0:
                      patterns: [
                        {
                          include: "#inline"
                        }
                      ]
                }
              ]
          # Tokenize row in <thead> table section.
          "h":
            scope: "row.thead.header"
            rule:
              patterns: [
                {
                  include: "#tableRow"
                }
              ]
          # Tokenize row in <tfoot> table section.
          "f":
            scope: "row.tfoot.footer"
            rule:
              patterns: [
                {
                  include: "#tableRow"
                }
              ]
          # Tokenize row in <tbody> table section.
          "":
            scope: "row.tbody.body"
            rule:
              patterns: [
                {
                  include: "#tableRow"
                }
              ]
        }...
      ]
    tableRow:
      # From processRow()
      patterns: [
        {
          comment: "Tokenize table cell."
          match: "(?<!$)(.*?)(\\||$)"
          captures:
            1:
              patterns: [
                {
                  match: "^#{type}$"
                  name: "#{scope}.meta.cell.td.tw5"
                  capture:
                    0:
                      name: "#{scope}.punctuation.definition.cell.tw5"
                } for type, scope of {
                  "~": "rowspan.down"
                  ">": "colspan.right"
                  "<": "colspan.left"
                }...
                # @IDEA:
                # Append alignment and header flags to the cell scope.
                # Will require too much rules, though.
                {
                  match: """(?x)
                  ^
                  (?:
                    (\\^(?:[^^]|\\^\\^)) |  # Top alignment marker
                    (\\,(?:[^,]|\\,\\,))    # Bottom alignment marker
                  )?
                  ([ \\t]*)                 # Left alignment marker
                  (#{marker})               # Heading cell marker
                  (.*?)                     # Cell contents
                  ([ \\t]*)                 # Right alignment marker
                  $
                  """
                  name: "#{scope}.meta.cell.tw5"
                  captures:
                    1:
                      name: "punctuation.definition.cell.valign.top.tw5"
                    2:
                      name: "punctuation.definition.cell.valign.bottom.tw5"
                    3:
                      name: "punctuation.definition.cell.align.left.tw5"
                    4:
                      name: "punctuation.definition.cell.heading.th.tw5"
                    5:
                      patterns: [
                        {
                          include: "#inline"
                        }
                      ]
                    6:
                      name: "punctuation.definition.cell.align.right.tw5"
                } for marker, scope of {
                  "!": "heading.th"
                  "": "data.td"
                }...
              ]
            2:
              name: "punctuation.separator.cell.pipe.inner.tw5"
        }
      ]

    # @IDEA: Maybe do recursive parsing of lists?
    list:
      patterns: [
        {
          begin: "^\\s*([\\*#;:>]*#{type}(?![\\*#;:>]))(#{regexes.classes})?"
          end: "$"
          name: "#{scope}.markup.list.tw5"
          captures:
            1:
              name: "#{scope}.punctuation.definition.list.markup.tw5"
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
        } for type, scope of {
          "\\*": "unnumbered.unordered.ul.li"
          "#": "numbered.ordered.ol.li"
          ";": "unnumbered.term.dl.dt"
          ":": "unnumbered.description.dl.dd"
          ">": "unnumbered.blockquote.quote"
        }...
      ]
    heading:
      patterns: [
        {
          begin: "^\\s*(!{#{i}})(#{regexes.classes})?"
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

#
# Section: Wiki text inline rules
#

    inline:
      patterns: [
        {
          include: "#emphasis"
        }
        {
          include: "#codeinline"
        }
        {
          include: "#styleinline"
        }
        {
          include: "#hardlinebreaks"
        }
        {
          include: "#macrocallinline"
        }
        {
          include: "#filteredtranscludeinline"
        }
        {
          include: "#transcludeinline"
        }
        {
          include: "#link"
        }
        {
          include: "#dash"
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
    styleinline:
      begin: "(@@)(#{regexes.styles})?(#{regexes.classes})?"
      end: "(@@)"
      name: "markup.other.style.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.style.markup.begin.tw5"
        2:
          patterns: [
            {
              include: "#styles"
            }
          ]
        3:
          patterns: [
            {
              include: "#classes"
            }
          ]
      endCaptures:
        1:
          name: "punctuation.definition.style.markup.end.tw5"
      patterns: [
        {
          include: "#inline"
        }
      ]
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
    macrocallinline:
      # @NOTE:
      # Copy of `macrocallblock` rule.
      begin: "(<<)([^>\\s]+)"
      end: "(>>)"
      name: "meta.function-call.macrocallinline.tw5"
      contentName: "meta.function.macro.parameters.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.macrocallinline.begin.tw5"
        2:
          name: "entity.name.function.macro.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.macrocallinline.end.tw5"
      patterns: [
        # @HACK:
        # Assume parameter name and value are on the same line.
        {
          # Match positional or named assignment of value, expressed by a quoted
          # string.
          #
          # @FIXME:
          # For some reason fails to stop eating strings in constructs like
          # these:
          #
          # ```
          # <<myMacro 'value1''value2'>>
          # <<myMacro "value1""value2">>
          # ```
          begin: "(?:([\\w\\-]+)\\s*(:)\\s*)?(?=#{begin})"
          end: "(?<=#{end})"
          name: "meta.function.macro.parameter.tw5"
          beginCaptures:
            1:
              name: "variable.parameter.tw5"
            2:
              name: "keyword.operator.assignment.tw5"
          patterns: [
            {
              include: "#string"
            }
          ]
        } for [begin, end] in [
          ["\"\"\"", "\"\"\""]
          ["\"", "\""]
          ["\'", "\'"]
          ["\\[\\[", "\\]\\]"]
        ]...
        {
          # Match positional or named assignment of value, expressed by an
          # unquoted string.
          match: "(?:([\\w\\-]+)\\s*(:)\\s*)?([^\\>\"\'\\s]+)"
          name: "meta.function.macro.parameter.tw5"
          captures:
            1:
              name: "variable.parameter.tw5"
            2:
              name: "keyword.operator.assignment.tw5"
            3:
              begin: "^"
              end: "$"
              patterns: [
                {
                  include: "#string"
                }
              ]
        }
        {
          comment: "Match separators."
          match: "[^\\w\\-\\>\\s]+"
          name: "punctuation.separator.function.macro.parameter.tw5"
        }
      ]
    filteredtranscludeinline:
      # @NOTE:
      # Copypaste of `filteredtranscludeblock`.
      begin: "(\\{\\{\\{)"
      end: "(\\}\\}\\})"
      name: "meta.transclusion.filteredtranscludeblock.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.transclusion.filteredtranscludeblock.begin.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.transclusion.filteredtranscludeblock.end.tw5"
      patterns: [
        {
          comment: "Tokenize template tiddler title."
          begin: "(\\|\\|)"
          end: "(?=\\}\\}\\})"
          beginCaptures:
            1:
              name: "punctuation.definition.transclusion.filteredtranscludeblock.template.tw5"
          patterns: [
            {
              comment: "Treat nearest non-whitespace line as template tiddler title."
              begin: "(?<=\\|\\|)\\G"
              end: "(?=\\S)((?:(?!\\}\\}\\}).)*?)\\s*(?=$|\\}\\}\\})"
              endCaptures:
                1:
                  name: "entity.other.name.tiddler.title.template.tw5"
            }
            {
              # If another non-whitespace character occurs below, start marking
              # things illegal.
              begin: "(?=\\S)"
              end: "(?=\\}\\}\\})"
              name: "invalid.illegal.multiline-tiddler-title.tw5"
            }
          ]
        }
        # Tokenize filter string.
        # makeFilterRule("(?=\\|\\||\\}\\}\\})")
        {
          begin: "\\G"
          end: "(?=\\|\\||\\}\\}\\})"
          name: "meta.filter.tw5"
          patterns: [
            {
              include: "#filter"
            }
          ]
        }
      ]
    transcludeinline:
      # @NOTE:
      # Mostly copypaste of `transcludeblock` rule.
      begin: "(\\{\\{)"
      end: "(\\}\\})"
      name: "meta.transclusion.transcludeinline.tw5"
      beginCaptures:
        1:
          name: "punctuation.definition.transclusion.transcludeinline.begin.tw5"
      endCaptures:
        1:
          name: "punctuation.definition.transclusion.transcludeinline.end.tw5"
      patterns: [
        {
          comment: "Tokenize template tiddler title."
          begin: "(\\|\\|)"
          end: "(?=\\}\\})"
          beginCaptures:
            1:
              name: "punctuation.definition.transclusion.transcludeinline.template.tw5"
          patterns: [
            {
              # Let a trimmed portion of the nearest line containing
              # non-whitespace char be a template tiddler title.
              comment: "Treat nearest non-whitespace line as template tiddler title."
              begin: "(?<=\\|\\|)\\G"
              end: "(?=\\S)((?:(?!\\}\\}).)*?)\\s*(?=$|\\}\\})"
              endCaptures:
                1:
                  name: "entity.other.name.tiddler.title.template.tw5"
            }
            {
              # If another non-whitespace character occurs below, start marking
              # things illegal.
              begin: "(?=\\S)"
              end: "(?=\\}\\})"
              name: "invalid.illegal.multiline-tiddler-title.tw5"
            }
          ]
        }
        {
          comment: "Tokenize text reference."
          begin: "(?<=\\{\\{)\\G"
          end: "(?=\\}\\}|\\|\\|)"
          patterns: [
            {
              # Detect and eat non-empty portion of the first line of text
              # reference if present.
              begin: "(?<=\\{\\{)\\G"
              end: """(?x)
              (?= \\}\\} | \\|\\|) | # Allow dropping text reference
              (\\S.*?)\\s* (?= $ | \\}\\} | \\|\\|)
              """
              endCaptures:
                1:
                  patterns: [
                    {
                      include: "#textReference"
                    }
                  ]
            }
            {
              # If another non-whitespace character occurs below, start marking
              # things illegal.
              begin: "(?=\\S)"
              end: "(?=\\|\\||\\}\\})"
              name: "invalid.illegal.multiline-text-reference.tw5"
            }
          ]
        }
      ]

    link:
      patterns: [
        {
          include: "#prettyextlink"
        }
        {
          include: "#prettylink"
        }
        {
          include: "#extlink"
        }
        {
          include: "#syslink"
        }
        {
          include: "#wikilink"
        }
      ]

    # @IDEA:
    # Test beforehand, whether URI part of the link is extlink/syslink/wikilink,
    # and style it explicitly? Or just include all those rules at once?
    prettyextlink:
      # @HACK:
      # Parse only single line links here, because can't distinguish `[ext[<URL>]]` and `[ext[<Text>|<URL>]]` beforehand
      # on multiple lines (no backtracking for `begin`/`end` rules).
      match: "(\\[(ext)\\[)(.*?)(\\]\\])"
      name: "meta.link.external.tw5"
      captures:
        1:
          name: "punctuation.definition.link.external.begin.tw5"
        2:
          name: "keyword.other.ext.definition.link.tw5"
        3:
          patterns: [
            {
              comment: "Parse links like [ext[<Link title>|<URI>]]"
              # @IDEA: Wipe whitespaces for inner scopes?
              match: "^((.*?))(\\|)((.*?))$"
              captures:
                1:
                  name: "entity.other.title.link.tw5"
                2:
                  name: "string.other.title.link.tw5"
                3:
                  name: "punctuation.definition.link.title.tw5"
                4:
                  name: "entity.other.link.tw5"
                5:
                  name: "markup.underline.link.external.tw5"
            }
            {
              comment: "Parse links like [ext[<URI>]]"
              match: "^.*$"
              name: "entity.other.link.tw5"
              captures:
                0:
                  name: "markup.underline.link.external.tw5"
            }
          ]
        4:
          name: "punctuation.definition.link.external.end.tw5"
    prettylink:
      match: "(\\[\\[)(.*?)(\\]\\])"
      name: "meta.link.tw5"
      captures:
        1:
          name: "punctuation.definition.link.begin.tw5"
        2:
          patterns: [
            {
              comment: "Parse links like [[<Link title>|<URI>]]"
              match: "^((.*?))(\\|)((.*?))$"
              captures:
                1:
                  name: "entity.other.title.link.tw5"
                2:
                  name: "string.other.title.link.tw5"
                3:
                  name: "punctuation.definition.link.title.tw5"
                4:
                  name: "entity.other.link.tw5"
                5:
                  name: "markup.underline.link.tw5"
            }
            {
              comment: "Parse links like [[<URI>]]"
              match: "^.*$"
              name: "entity.other.link.tw5"
              captures:
                0:
                  name: "markup.underline.link.tw5"
            }
          ]
        3:
          name: "punctuation.definition.link.end.tw5"

    # @IDEA: Maybe add scoping for __explicitly__ suppressed links (preceeded by `~` by default)?
    extlink:
      # @NOTE:
      # Atom's builtin `language-hyperlink` grammar injects itself to `text` scope,
      # so without cancelling its rules out, links, preceeded by `~`, will be parsed by that grammar.
      match: "(?<!#{regexes.unWikiLink})(#{regexes.schemes}):[^\\s<>{}\\[\\]`|'\"\\\\^~]+"
      name: "markup.underline.link.external.$1.tw5"
    syslink:
      match: "(?<!#{regexes.unWikiLink})(\\$:\\/)[\\w\\/\\.\\-]+"
      captures:
        1:
          name: "punctuation.definition.link.wiki-link.syslink.tw5"
      name: "markup.underline.link.wiki-link.syslink.tw5"
    wikilink:
      match: "(?<!#{regexes.unWikiLink})(?<!#{regexes.blockPrefixLetters})(?:#{regexes.wikiLink})"
      name: "markup.underline.link.wiki-link.tw5"

    dash:
      patterns: [
        {
          match: "#{mark}(?!-)"
          name: "#{scope}.markup.other.dash.tw5"
        } for mark, scope of {
          "--": "ndash"
          "---": "mdash"
        }...
      ]
#
# Section: Shared helper rules
#

    # From WikiParser::parseClasses()
    classes:
      match: regexes.classes
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
    styles:
      match: regexes.styles
      name: "meta.support.styles.tw5"
      captures:
        0:
          patterns: [
            {
              match: "([^\\s]+?)(\\:)(.+?)(;)"
              name: "meta.property-value.css"
              captures:
                1:
                  name: "support.type.property-name.css"
                2:
                  name: "punctuation.separator.key-value.css"
                3:
                  patterns: [
                    include: "source.css#property-values"
                  ]
                4:
                  name: "punctuation.terminator.rule.css"
            }
          ]
    # From Wiki::parseFilter()
    # @HACK:
    # For now use single rule and don't depend on end patterns for specific
    # constructs using filters. So end patterns of outer constructs should be
    # separated from filter string (especially when using unqouted title
    # operator shortcut).
    #
    # E.g. those would fail:
    #
    # ```
    # {{{title}}}
    # {{{title||template}}}
    # <$list filter="title" />
    # ```
    #
    # And those won't:
    #
    # ```
    # {{{title }}}
    # {{{title ||template}}}
    # <$list filter="title " />
    # {{{'title'}}}
    # {{{'title' ||template}}}
    # <$list filter="'title'" />
    # {{{[[title]]}}}
    # {{{[[title]] ||template}}}
    # <$list filter="[[title]]" />
    # ```
    filter:
      patterns: [
        {
          # Match explicit filter operation syntax
          comment: "Match filter operation (run)."
          begin: "(?:(\\+)|(\\-))?(\\[)"
          end: "(\\])"
          name: "meta.filter.operation.run.tw5"
          contentName: "entity.filter.operator.step.title.tw5"
          beginCaptures:
            1:
              name: "keyword.operator.prefix.plus.replacement.tw5"
            2:
              name: "keyword.operator.prefix.minus.difference.tw5"
            3:
              name: "punctuation.definition.filter.operation.begin.tw5"
          endCaptures:
            1:
              name: "punctuation.definition.filter.operation.end.tw5"
          patterns: [
            {
              # @NOTE:
              # It seems like duplicating this rule for each operand type is the
              # only way to achieve the desired scoping. Otherwise no viable way
              # to detect the end of single operator in chain of operators.
              # @IDEA:
              # Maybe store captured operator name/suffix in scope names.
              # @IDEA:
              # Process specific operands explicitly (e.g. provide regex
              # highlighting).
              # @HACK:
              # For now ignore deprecated regex operand support.
              # @HACK:
              # Consider operator name and suffix, and operand one liner.
              comment: "Match filter operator (step)."
              match: "(!?)([^\\[\\{<]*?)(?:(:)([^\\[\\{<]*?))?((#{begin})(.*?)(#{end}))"
              name: "meta.filter.operator.step.tw5"
              captures:
                1:
                  name: "keyword.operator.prefix.not.negation.tw5"
                2:
                  name: "entity.filter.operator.step.name.tw5"
                3:
                  name: "punctuation.definition.filter.operator.suffix.tw5"
                4:
                  name: "entity.filter.operator.step.suffix.tw5"
                5:
                  name: "#{scope}.entity.operand.tw5"
                6:
                  name: "#{scope}.punctuation.definition.operand.begin.tw5"
                # @NOTE:
                # __Problem__:
                # Injections doesn't seem to work within `match` rule.
                #
                # __Options__:
                # * Directly include rules, ugly and strightforward
                # * Append a `begin/`end` rule here, assign helper scope, inject
                #
                # __Solution__:
                # No meaningful additional scope name to assign, so use the ugly
                # option.
                7: rule ? {}
                8:
                  name: "#{scope}.punctuation.definition.operand.end.tw5"
            } for [begin, end, scope, rule] in [
              ["<", ">", "variable"]
              ["\\[", "\\]", "direct"]
              [
                "\\{", "\\}", "indirect", {
                  patterns: [
                    {
                      include: "#textReference"
                    }
                  ]
                }
              ]
            ]...
          ]
        }
        # Define rules matching shortcuts of operation with single `title`
        # operator.
        {
          begin: "(?:(\\+)|(\\-))?(?=#{mark})"
          end: "(?<=#{mark})"
          name: "meta.filter.operation.run.tw5"
          contentName: "entity.filter.operator.step.title.tw5"
          beginCaptures:
            1:
              name: "keyword.operator.prefix.plus.replacement.tw5"
            2:
              name: "keyword.operator.prefix.minus.difference.tw5"
          patterns: [
            {
              include: "#string"
            }
          ]
        } for mark in ["\"", "\'"]...
        {
          match: "(?:(\\+)|(\\-))?(\\S+)"
          name: "meta.filter.operation.run.tw5"
          captures:
            1:
              name: "keyword.operator.prefix.plus.replacement.tw5"
            2:
              name: "keyword.operator.prefix.minus.difference.tw5"
            3:
              patterns: [
                {
                  match: "^.*$"
                  name: "entity.filter.operator.step.title.tw5"
                  captures:
                    0:
                      patterns: [
                        {
                          include: "#string"
                        }
                      ]
                }
              ]
        }
      ]
    # From $tw.utils.parseTextReference()
    # @IDEA:
    # May improve scoping.
    # __Options__:
    # * Insert captured field/index name into scope name.
    #   Fast, simple, but will lead to unexpected styling.
    # * Use `codeblock` approach.
    #   Will have to trim things down and apply patterns.
    textReference:
      match: "^(.*?)(?:(!!)(.*)|(\\#\\#)(.*))?$"
      name: "meta.support.text-reference.tw5"
      captures:
        0:
          name: "string.other.text-reference.tw5"
        1:
          name: "entity.other.name.tiddler.field.tiddler-field.title.tw5"
        2:
          name: "punctuation.definition.text-reference.field.tiddler-field.tw5"
        3:
          name: "entity.other.name.tiddler.field.tiddler-field.tw5"
        4:
          name: "punctuation.definition.text-reference.index.data-index.tiddler-index.tw5"
        5:
          name: "entity.other.name.tiddler.index.data-index.tiddler-index.tw5"
    string:
      patterns: [
        {
          begin: begin
          end: end
          name: "#{scope}.string.quoted.tw5"
          beginCaptures:
            0:
              name: "#{scope}.punctuation.definition.string.begin.tw5"
          endCaptures:
            0:
              name: "#{scope}.punctuation.definition.string.end.tw5"
        } for [begin, end, scope] in [
          ["\"\"\"", "\"\"\"", "triple"]
          ["\"",     "\"",     "double"]
          ["\'",     "\'",     "single"]
          ["\\[\\[", "\\]\\]", "parens.square"]
        ]...
        {
          match: "\\S+"
          name: "string.unquoted.tw5"
        }
      ]

module.exports = grammar
