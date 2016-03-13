# language-tiddlywiki5

A package for [Atom](https://atom.io) text editor, that provides a bunch of grammars to support wikitext and specific file formats, recognized by [TiddlyWiki5](http://tiddlywiki.com/), a non-linear web notebook.

## Grammars

This package provides the following grammars:

|Name                    |Description                                                          |
|------------------------|---------------------------------------------------------------------|
|TiddlyWiki5             |[TW5 wiki markup](http://tiddlywiki.com/WikiText)                    |
|TiddlyWiki5 dictionary  |[Data dictionary](http://tiddlywiki.com/#DictionaryTiddlers)         |
|TiddlyWiki5 tid file    |[__*.tid__](http://tiddlywiki.com/#TiddlerFiles) file format         |
|TiddlyWiki5 meta file   |[__*.meta__](http://tiddlywiki.com/#TiddlerFiles) file format        |
|TiddlyWiki5 multids file|[__*.multids__](http://tiddlywiki.com/#MultiTiddlerFiles) file format|

## Hacks and tips

### Automatic grammar detection

There are browser extensions for editing text using external text editors:

* [It'sAllText!](https://addons.mozilla.org/en-US/firefox/addon/its-all-text/)
* [GhostText](https://addons.mozilla.org/en-US/firefox/addon/ghosttext-for-firefox/)

In TW5 web GUI you would input plain wikitext without tiddler metadata. As there's no file extension for wiki markup only, recognized by TW5, using those extensions above would require selecting grammar manually, which is tedious.

Grammars provide two features to assist in solving this problem:

* Fake file type extensions
* First line patterns

#### Fake file type extensions

Here's a list of grammars and fake extensions they apply to:

|Name                  |Extensions|
|----------------------|----------|
|TiddlyWiki5           |__*.tw5__ |

Configure browser extensions to use these file type extensions above, so temporary files they span would be properly recognized.

#### First line patterns

Provide a set of first line patterns for grammars to match, so the grammar would be detected by content, not by file extension.

Here's a list of grammars and first line patterns they match:

|Name                  |Patterns    |
|----------------------|------------|
|TiddlyWiki5           |`<!--TW5-->`|

## License

[MIT](./LICENSE.md)
