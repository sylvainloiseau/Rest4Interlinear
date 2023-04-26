Browse interlinear glossed text corpus (in Emeld XML format) and associated lexical data (in Lift XML format).

- The [Emeld vocabulary](https://www.researchgate.net/publication/244446092_Towards_a_general_model_of_interlinear_text) represent interlinear glossed texts. It can be produced by [SIL Fiedlworks](https://software.sil.org/fieldworks/download/) or [Elan](https://archive.mpi.nl/tla/elan).
  - See : Cathy Bow, Baden Hughes, Steven Bird, (2003) "Towards a general model of interlinear text", Proceedings of Emeld workshop 2003.
- The [Lift (Lexical Interchange Format Standard) vocabulary](https://code.google.com/archive/p/lift-standard/). It is also an export format of SIL Fiedlworks and Elan.

The display is defined in XQuery files and can be very easily adapted to specific needs.

# Dependencies

- [BaseX XML database](https://basex.org/)
- Optional: In order to be able to export texts into PDF, you need a XSLT processor on your java classpath and a latex installation on your system

# Installation

- Install BaseX
- In BaseX, create a database from an Emeld document, containg the interlinear texts, and a database from a Lift document, containing the dictionary
- Checkout this repository
- Create a file `.basex` (see the example in `basex.sample`), for instance in your home directory
- edit the variables `$common:LexiconDataBaseName` and `$common:TextsDataBaseName` in `webapp/xq/variable.xqm` in order to point the intended basex databases.

# Run

- run bin/basexhttp from the directory containing your `.basex` file
- open a browser and go to [http://localhost:8984/Index](http://localhost:8984/Index)

# Sample

## List of texts

![List of texts](doc/img/ListOfTexts.png?raw=true "List of texts")

## Text

![Text](doc/img/Text.png?raw=true "Text")

## Lexicon

![Lexicon](doc/img/Lexicon.png?raw=true "Lexicon")

## Lexicon entry detail

![Lexicon entry detail](doc/img/formDetail.png?raw=true "Lexicon entry detail")
