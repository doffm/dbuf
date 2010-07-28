
# Architecture

dbuf uses antlr3 for virtually everything including parsing and output generation.
People looking to hack on dbuf will need to learn about antlr, resources for which
can be found at:

        http://www.antlr.org/

dbuf is a parser for a language that describes D-Bus messages.

The parser grammar is described in `src/grammar/dbuf.g` describes a parser for this
language. This grammar parses files in the dbuf language and outputs an abstract
syntax tree as well as a list of symbols that have been declared.

The grammar `src/grammar/dbuflink.g` is used to link undefined symbols (Type identifiers
or names) to the tree nodes that they represent.

The grammar `src/grammar/dbufsignature.g` is used to output a D-Bus signature for
types that have a signature. It assumes that linking has occured. This is neccessary
as to calculate a signature all dependant types must be evaluated for their signature.

The grammars `src/grammar/dbufoutput.g` and `src/grammar/dbufxmloutput.g` are
output grammars. The first is used to output a text xml that closely resembles the AST.
The second is used to output D-Bus XML.

# Completed

The core language is complete and an output generator has been created to output
D-Bus XML.

# Known bugs

- Recursive data structures are not allowed but there is currently no check for this.
  When calculating a signature a recursive data structure will cause an infinite loop.
  (Or more likely a stack overflow as the algorithm for calculating a signature is recursive.)
  A method is needed to detect recursive data structures and throw an error when they occur.

- Shadowing types. If a type in the current namespace (And sub-namespaces) shadows one that is accessible
  from the root namespace then there is no way to access the root namespace symbol.

# Future directions

There are a number of directions in which dbuf could be taken. Firstly new output formats
could be created. There are a number of non-standard ways to describe D-Bus protocols such
as Telepathy D-Bus XML, Qt D-Bus annotations and GDBus XML. I believe that the core language
contains enough information to do simple outputs in these formats.

It is also possible that the core language contains enough information to do code generation
for D-Bus bindings in 'C' and 'C++'. The language currently omits any way to do annotations
which may make translating types in the dbuf language to 'C' or 'C++' type names difficult.

Currently comments are not included in the token stream. This makes it impossible to do HTML
or any other form of documentation generation.

## Feature requests

- Create output templates / grammars for Qt D-Bus XML, Telepathy D-Bus XML, Egg DBus XML.

- Design and create configuration files / separate language (Very simple) that describes
  how message formats should appear in target languages and D-Bus bindings. This is
  essentially an annotations language. Annotations could also be built in to the core language.

- Create code generation templates / grammars for libdbus, QtDBus, Python D-Bus.

- Add the comments in to the token stream so that documentation output targets can be created.
