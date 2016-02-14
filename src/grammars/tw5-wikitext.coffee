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
          include: "#rules"
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
          include: "#transcludeblock"
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
              end: "(\\S.*?)\\s*(?=$|\\}\\})"
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
          include: "#link"
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

module.exports = grammar