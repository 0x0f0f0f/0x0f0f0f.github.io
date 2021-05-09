@def title = "LaTeX notetaking: TeXStudio VS. LaTeX Workshop for VS Code"
@def rss =  "LaTeX notetaking: TeXStudio VS. LaTeX Workshop for VS Code"
@def published = "06 December 2019"
@def tags = ["latex", "programming", "math"]

## LaTeX in brief
**[LaTeX](https://en.wikipedia.org/wiki/LaTeX)** is the most used document
preparation system in the academia world, derived from the *TeX* typesetting
system, first written by the Legendary [Donald
Knuth](https://en.wikipedia.org/wiki/Donald_Knuth). It is a textual markup
language for producing digitally distributed files, ready to be printed. In this
article I will not cover the basics of LaTeX. If you want to learn more, you can
head over to the excellent [WikiBook](https://en.wikibooks.org/wiki/LaTeX).
If you have any questions you can query the huge database of answered
questions at [Tex Stack Exchange](https://tex.stackexchange.com/)

I first stumbled into LaTeX as a first year computer science student, I was
taking lecture notes in markdown and I wanted to include mathematical notation
in them. At first, I've started using [MathJax](https://www.mathjax.org/), a
cross-browser JavaScript library used to display mathematical notation in
browsers; I didn't know anything about the TeX world yet, except that it was the
standard for writing books and scientific papers. I kept taking notes in
markdown for a couple of months while thinking that LaTeX was somehow
complicated and esoteric, until one day. I was in my discrete maths and linear
algebra Professor's office to ask some questions related to the courses. Prof.
Berarducci, always eager to answer his students' questions,
noticed that I was making a mess by mixing up markdown and LaTeX.
He began to show me how he writes notes, slides and papers using **TeXStudio**,
and he showed me some tips and tricks to write
[preludes](https://www.overleaf.com/learn/latex/Multi-file_LaTeX_projects) for
projects that make use of a lot of mathematical notation. This is how I've got
introduced to the world of writing LaTeX. In less than half an hour I had the
knowledge to write not perfect, but at least readable lecture notes in a basic
Mathematics course.

## TeXStudio, the good and the bad.
[TeXStudio](http://www.texstudio.org/) is a cross-platform open-source LaTeX
editor and IDE. It is a great TeX writing environment if it is your first time
approaching LaTeX. The UX is fine, what you have is an almost WYSIWYG editor
written in C++ using the Qt GUI toolkit. There are configurable shortcuts for
almost everything, from inserting environments to handling tables and files.
What you have is also a nicely documented set of menus and buttons, that help you
format and insert symbols, graphics, figures, environments into your documents.
I've installed TeXStudio from
[flatpak](https://flathub.org/apps/details/org.texstudio.TeXstudio), the package
already contains a LaTeX distribution to compile your documents, which is not
included if you install TeXStudio manually on your system. Flatpak-ed
applications also have their own advantages and downsides, but I will not focus
on discussing them this time.

![A screenshot of TeXStudio](/assets/images/texstudio.png)

The downsides of TeXStudio are many. The first one is that it is configured in
a single `.ini` file, making it quite annoying to configure if not from the
graphical interface. This also makes it hard to sync TeXStudio settings across
different machines. The themes are not so great looking and the PDF viewer has
some noteworthy bugs. Another downside is that when you first *level up* from
discovering LaTeX, and begin to take lecture notes in the editor, the default
keyboard shortcuts are not friendly for *sped up* typing. The flatpak install is
also quite bulky (1.8 GB since it includes a full LaTeX compiler distribution).

## Migrating to Visual Studio Code
If I have to write code or text for small projects, I use the amazing
[kakoune](https://kakoune.org/) editor, if I'm working on big projects where
advanced code linting, autocompletion and IDE features are needed [Visual Studio
Code](https://code.visualstudio.com/) is my editor of choice. The editor itself
is great. There is a [good set](https://github.com/viatsko/awesome-vscode) of
available extensions that you can install with a click, it is relatively fast
and it provides everything you may need for working with version control in your
repositories. There is also support for external debuggers, a full-screen zen
mode and it is configured with JSON files (more on configuration in the next
paragraphs). A noticeable downside is that it is written in Electron, and here
why [Electron is considered
harmful](https://drewdevault.com/2016/11/24/Electron-considered-harmful.html)
(but VSCode is still a great text editor).

For my LaTeX documents, I've migrated from TeXStudio to VSCode because I want to
use a single text editor for all of my projects. You need to have a working LaTeX
distribution with the `tlmgr` package manager to install the packages that you
are going to include in your files.

## Here are the extension and config files I'm using for TeX-ing in VSCode:

### Extensions:

1. [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop):
    An extension that boosts LaTeX typesetting efficiency with preview, compile,
    autocomplete, colorize, and more.
2. [Rewrap](https://marketplace.visualstudio.com/items?itemName=stkb.rewrap):
    Re-wraps comments and other text to a given line length.
3. [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync):
    Synchronize Settings, Snippets, Themes, File Icons, Launch, Keybindings,
    Workspaces and Extensions Across Multiple Machines Using GitHub Gist.
4. [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree):
    Show a tree of comments containing `TODO` in your code project. Really helpful to get stuff done!
5. [Prettify Symbols Mode](https://marketplace.visualstudio.com/items?itemName=siegebell.prettify-symbols-mode):
    Displays identifiers & symbols using more aesthetically pleasing symbols.
5. The [Srcery color scheme](https://marketplace.visualstudio.com/items?itemName=srcery-colors.srcery-colors)

### Writing Computer Architecture Notes in zen-mode VSCode:
![Writing Computer Architecture Notes in VSCode](/assets/images/vscodetex1.png)

### Writing Probability Notes in zen-mode VSCode:
![Writing Probability Notes in VSCode](/assets/images/vscodetex2.png)

### Configuration Files:

Here is my `settings.json` file, with the most important section being `prettifySymbolsMode.substitutions`.
In that sections you can specify which identifiers are to be substituted by the
"*pretty*" symbols by the **Prettify Symbols Mode** extension. When your cursor
falls on the prettified symbol, the "real" (ugly) text will be displayed. This
is a really useful feature for writing LaTeX because you can replace an ugly command like
`\alpha` with the human readable Unicode character counterpart `α` in the source
code. This make editing mathematical formulas a lot more pleasing than, let's
say, writing them in TeXStudio.
My settings file contains **LaTeX**, Haskell and OCaml identifiers with their pretty substitutions.

Find the configuration files in this [Github
Gist](https://gist.github.com/0x0f0f0f/fb9d1b950587e32f650cd01d7328b5b1).

`settings.json`
```json
{
    "window.zoomLevel": 0,
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "latex-workshop.chktex.enabled": true,
    "latex-workshop.synctex.afterBuild.enabled": true,
    "latex-workshop.view.pdf.viewer": "tab",
    "editor.fontSize": 12,
    "prettifySymbolsMode.revealOn": "cursor",
    "prettifySymbolsMode.adjustCursorMovement": false,
    "prettifySymbolsMode.substitutions": [{
      "language": "latex",
      "revealOn": "selection",
      "substitutions": [
        { "ugly": "\\\\alpha",      "pretty": "α" },
        { "ugly": "\\\\beta",       "pretty": "β" },
        { "ugly": "\\\\gamma",      "pretty": "γ" },
        { "ugly": "\\\\delta",      "pretty": "δ" },
        { "ugly": "\\\\epsilon",    "pretty": "ε" },
        { "ugly": "\\\\zeta",       "pretty": "ζ" },
        { "ugly": "\\\\eta",        "pretty": "η" },
        { "ugly": "\\\\theta",      "pretty": "θ" },
        { "ugly": "\\\\iota",       "pretty": "ι" },
        { "ugly": "\\\\kappa",      "pretty": "κ" },
        { "ugly": "\\\\lambda",     "pretty": "λ" },
        { "ugly": "\\\\mu",         "pretty": "μ" },
        { "ugly": "\\\\nu",         "pretty": "ν" },
        { "ugly": "\\\\xi",         "pretty": "ξ" },
        { "ugly": "\\\\omikron",    "pretty": "o" },
        { "ugly": "\\\\pi",         "pretty": "π" },
        { "ugly": "\\\\rho",        "pretty": "ρ" },
        { "ugly": "\\\\sigma",      "pretty": "σ" },
        { "ugly": "\\\\tau",        "pretty": "τ" },
        { "ugly": "\\\\upsilon",    "pretty": "υ" },
        { "ugly": "\\\\phi",        "pretty": "φ" },
        { "ugly": "\\\\chi",        "pretty": "χ" },
        { "ugly": "\\\\psi",        "pretty": "ψ" },
        { "ugly": "\\\\omega",      "pretty": "ω" },
        { "ugly": "\\\\Alpha",      "pretty": "Α" },
        { "ugly": "\\\\Beta",       "pretty": "Β" },
        { "ugly": "\\\\Gamma",      "pretty": "Γ" },
        { "ugly": "\\\\Delta",      "pretty": "Δ" },
        { "ugly": "\\\\Epsilon",    "pretty": "Ε" },
        { "ugly": "\\\\Zeta",       "pretty": "Ζ" },
        { "ugly": "\\\\Eta",        "pretty": "Η" },
        { "ugly": "\\\\Theta",      "pretty": "Θ" },
        { "ugly": "\\\\Iota",       "pretty": "Ι" },
        { "ugly": "\\\\Kappa",      "pretty": "Κ" },
        { "ugly": "\\\\Lambda",     "pretty": "Λ" },
        { "ugly": "\\\\Mu",         "pretty": "Μ" },
        { "ugly": "\\\\Nu",         "pretty": "Ν" },
        { "ugly": "\\\\Xi",         "pretty": "Ξ" },
        { "ugly": "\\\\Omikron",    "pretty": "O" },
        { "ugly": "\\\\Pi",         "pretty": "Π" },
        { "ugly": "\\\\Rho",        "pretty": "Ρ" },
        { "ugly": "\\\\Sigma",      "pretty": "Σ" },
        { "ugly": "\\\\Tau",        "pretty": "Τ" },
        { "ugly": "\\\\Upsilon",    "pretty": "Υ" },
        { "ugly": "\\\\Phi",        "pretty": "Φ" },
        { "ugly": "\\\\Chi",        "pretty": "Χ" },
        { "ugly": "\\\\Psi",        "pretty": "Ψ" },
        { "ugly": "\\\\Omega",      "pretty": "Ω" },
        { "ugly": "\\\\rightarrow",   "pretty": "→" },
        { "ugly": "\\\\equiv",      "pretty": "≡" },
        { "ugly": "\\\\forall",     "pretty": "∀" },
        { "ugly": "\\\\lnot",       "pretty": "¬" },
        { "ugly": "\\\\sum",        "pretty": "Σ" },
        { "ugly": "\\\\implies",    "pretty": "⇒" },
        { "ugly": "\\\\iff",        "pretty": "⇔" },
        { "ugly": "\\\\emptyset",   "pretty": "∅" },
        { "ugly": "\\\\in",         "pretty": "∈", "post": "(?!\\w)|$" },
        { "ugly": "\\\\subset",     "pretty": "⊂", "post": "(?!\\w)|$" },
        { "ugly": "\\\\cup",        "pretty": "∪", "post": "(?!\\w)|$" },
        { "ugly": "\\\\cap",        "pretty": "∩", "post": "(?!\\w)|$" },
        { "ugly": "\\\\subseteq",   "pretty": "⊆" },
        { "ugly": "\\\\neq",        "pretty": "≠" },
        { "ugly": "\\\\exists",     "pretty": "∃" },
        { "ugly": "\\\\mid",        "pretty": "|" },
        { "ugly": "\\\\land",       "pretty": "∧" },
        { "ugly": "\\\\lor",        "pretty": "∨" },
        { "ugly": "\\\\cdot",       "pretty": "·" },
        { "ugly": "\\\\to",         "pretty": "→" },
        { "ugly": "\\\\left\\(",    "pretty": "(" },
        { "ugly": "\\\\left\\[",    "pretty": "[" },
        { "ugly": "\\\\left\\{",    "pretty": "{" },
        { "ugly": "\\\\right\\)",   "pretty": ")" },
        { "ugly": "\\\\right\\]",   "pretty": "]" },
        { "ugly": "\\\\right\\}",   "pretty": "}" },
        { "ugly": "\\\\infty",      "pretty": "∞" },
        { "ugly": "\\\\geq",        "pretty": "≥" },
        { "ugly": "\\\\leq",        "pretty": "≤" },
        { "ugly": "\\\\int",        "pretty": "∫" },
        { "ugly": "\\\\iint",        "pretty": "∫∫" },
        { "ugly": "\\\\C",        "pretty": "ℂ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\R",        "pretty": "ℝ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\N",        "pretty": "ℕ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\Q",        "pretty": "ℚ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\Z",        "pretty": "ℤ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\mathbb\\{C\\}",        "pretty": "ℂ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\mathbb\\{R\\}",        "pretty": "ℝ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\mathbb\\{N\\}",        "pretty": "ℕ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\mathbb\\{Q\\}",        "pretty": "ℚ", "post": "(?!\\w)|$" },
        { "ugly": "\\\\mathbb\\{Z\\}",        "pretty": "ℤ", "post": "(?!\\w)|$" }
      ]}, {
        "language": ["lisp", "scheme"],
        "revealOn": "selection",
        "substitutions": [
          { "ugly": "lambda",   "pretty": "λ" },
        ]}, {
      "language": "haskell",
      "revealOn": "selection",
      "substitutions": [
        { "ugly": "\\\\",     "pretty": "λ", "post": "\\s*(?:\\w|_).*?\\s*->" },
        { "ugly": "->",       "pretty": "→" },
        { "ugly": "<-",       "pretty": "←" },
        { "ugly": "&&",       "pretty": "∧" },
        { "ugly": "||",       "pretty": "∨" },
        { "ugly": "\\.",        "pretty": "∘",  "pre": "\\s"},
        { "ugly": "==",       "pretty": "≡" },
        { "ugly": "forall",   "pretty": "∀", "pre": "\\b", "post": "\\b" },
        { "ugly": "not\\s?",  "pretty": "¬", "pre": "\\b", "post": "\\b" },
        { "ugly": ">",        "pretty": ">", "pre": "[^=\\-<>]|^", "post": "[^=\\-<>]|$" },
        { "ugly": "<",        "pretty": "<", "pre": "[^=\\-<>]|^", "post": "[^=\\-<>]|$" },
        { "ugly": ">=",       "pretty": "≥", "pre": "[^=\\-<>]|^", "post": "[^=\\-<>]|$" },
        { "ugly": "<=",       "pretty": "≤", "pre": "[^=\\-<>]|^", "post": "[^=\\-<>]|$" }
      ]},{
      "language": "ocaml",
      "revealOn": "selection",
      "adjustCursorMovement": true,
      "substitutions": [
        { "ugly": "fun",            "pretty": "λ", "pre": "\\b", "post": "\\b" },
        { "ugly": "->",             "pretty": "→", "pre": "[^->]", "post": "[^->]" },
        { "ugly": "List[.]for_all", "pretty": "∀", "pre": "\\b", "post": "\\b" },
        { "ugly": "List[.]exists",  "pretty": "∃", "pre": "\\b", "post": "\\b" },
        { "ugly": "List[.]mem",     "pretty": "∈", "pre": "\\b", "post": "\\b" },
        { "ugly": "\\|",            "pretty": "|", "pre": "^\\s+" }
      ]},{
      "language": "fsharp",
      "substitutions": [
        { "ugly": "fun",           "pretty": "λ", "pre": "\\b", "post": "\\b" },
        { "ugly": "->",            "pretty": "→", "pre": "[^->]", "post": "[^->]" },
        { "ugly": "List[.]forall", "pretty": "∀", "pre": "\\b", "post": "\\b" },
        { "ugly": "List[.]exists", "pretty": "∃", "pre": "\\b", "post": "\\b" },
        { "ugly": ">>",            "pretty": "≫", "pre": "[^=<>]|^", "post": "[^=<>]|$" },
        { "ugly": "<<",            "pretty": "≪", "pre": "[^=<>]|^", "post": "[^=<>]|$" },
        { "ugly": "\\|",           "pretty": "║", "pre": "^\\s+" }
      ]
    }
  ],  "debug.console.fontSize": 12,
  "terminal.integrated.fontSize": 12,
  "workbench.iconTheme": "vs-minimal",
  "editor.minimap.enabled": false,
  "editor.wordWrap": "wordWrapColumn",
  "breadcrumbs.enabled": true,
  "editor.renderControlCharacters": true,
  "zenMode.hideLineNumbers": false,
  "workbench.colorTheme": "Srcery-gagbo"
}
```

Here are some useful snippets (LaTeX Workshop already has a [ton of useful
snippets](https://github.com/James-Yu/LaTeX-Workshop/wiki/Snippets)!) that you
can use.

`latex.json` (Edit with `Preferences: Configure User Snippets`)
```json
{
	"definition": {
		"prefix": "DEF",
		"body": [
			"\\begin{defn}",
			"\t\\textbf{$1} \\\\\\",
			"\t$2",
			"\\end{defn}",
			"$2"
		]
	},
	"proof": {
		"prefix": "PROOF",
		"body": [
			"\\begin{proof}",
			"\t$1",
			"\\end{proof}",
			"$2"
		]
	},
	"example": {
		"prefix": "EXMP",
		"body": [
			"\\begin{exmp}",
			"\t$1",
			"\\end{exmp}",
			"$2"
		]
	},
	"exercise": {
		"prefix": "EXRC",
		"body": [
			"\\begin{exrc}",
			"\t$1",
			"\\end{exrc}",
			"$2"
		]
	},
	"alignedequation" : {
		"prefix": "BEQAL",
		"body": [
			"\\begin{equation*}",
			"\t\\begin{aligned}",
			"\t\t$1",
			"\t\\end{aligned}",
			"\\end{equation*}"
		]
	}
}
```


## Other valid alternatives

If you don't like Visual Studio Code (for ethical or practical causes), or you
use another editor you can take a look at other great LaTeX plugins/writing
environments:

* [AUCTeX](https://www.gnu.org/s/auctex/), an extensible package for writing and
  formatting TeX files in GNU **Emacs**. It is used by a lot of UNIX veterans
  equipped with ancient wizardry.
* If you need to do real time collaborations or you do not want to install
  additional software on you machine,
  [Overleaf](https://www.overleaf.com/learn/latex/Multi-file_LaTeX_projects) is
  the best choice. Albeit quite slow (because it resides in the browser), it is
  a fully fledged TeX editor that makes a good choice, especially for large
  collaborative projects.


## Huge Thanks to:

* [Alessandro Berarducci](https://scholar.google.it/citations?user=OcKbCO0AAAAJ)
  for introducing me to the world of LaTeX and TeXstudio
* [loures](http://github.com/loures) for giving me useful advice on how to
  format my notes.
* [rei](http://stellameravigliosa.io/) a powerful ancient wizard.