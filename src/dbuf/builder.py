import antlr3
import antlr3.tree
import stringtemplate3

import os.path
from StringIO import StringIO

from dbufLexer import dbufLexer
from dbufParser import dbufParser
from dbuflink import dbuflink
from dbufxmloutput import dbufxmloutput

from node import DbufTreeAdaptor
from symbols import SymbolTable

import templates

class InterfaceNotFoundError (Exception):
        def __init__ (self, msg=None):
                self.message = msg
                Exception.__init__(self, msg)

        def _get_message(self):
                return self._message
        def _set_message(self, message):
                self._message = message
        message = property(_get_message, _set_message)

class ParsingError (Exception):
        def __init__ (self, msg=None):
                self.message = msg
                Exception.__init__(self, msg)

        def _get_message(self):
                return self._message
        def _set_message(self, message):
                self._message = message
        message = property(_get_message, _set_message)

def parse (filename):
        """
        Parse a single file and return a 'SymbolStash' containing
        the symbols defined within it, the root AST node of the parsed
        file and a token stream of the parsed file.

        (defined, node, tokens)
        """

        input = antlr3.FileStream (filename)
        lexer = dbufLexer (input)
        tokens = antlr3.CommonTokenStream (lexer)
        parser = dbufParser (tokens)
        parser.setSourceFile (os.path.abspath (filename))

        adaptor = DbufTreeAdaptor ()
        parser.setTreeAdaptor (adaptor)

        res = parser.idl (tokens)

        if parser.parsingErrors:
                raise ParsingError ("Errors have occured parsing the file %s" % (filename))

        return (res.definedSymbols, res.tree, tokens)

def compile (filenames):
        """
        Parse all the provided files and then resolve
        symbols between them.

        Return a 'SymbolTable' containing symbols defined in all the
        files.
        """

        table = SymbolTable ()
        parsed = []

        for filename in filenames:
                defined, root, tokens = parse (filename)
                table.addModuleSymbols (defined)
                parsed.append ((root, tokens))

        for root, tokens in parsed:
                nodes = antlr3.tree.CommonTreeNodeStream (root)
                nodes.setTokenStream (tokens)
                linker = dbuflink (nodes)
                linker.idl (table)

        return table

def output (filenames, interfaces=[]):
        """
        Compile the provided files and return all the provided interfaces
        as a StringTemplate.
        """

        dbusxmlgroup = stringtemplate3.StringTemplateGroup (file=StringIO(templates.dbusxml))

        symbols = compile (filenames)

        # Default behavior is to output all interfaces when none are provided.
        if (not interfaces):
                for fqn, symbol in symbols.items():
                        if symbol.token.text == 'interface':
                                interfaces.append (fqn)

        interfaceoutputs = []

        for interface in interfaces:
                if interface in symbols:
                        root = symbols[interface]
                        if root.token.text == 'interface':
                                nodes = antlr3.tree.CommonTreeNodeStream (root)
                                nodes.setTokenStream (root.tokens)
                                walker = dbufxmloutput (nodes)
                                walker.setTemplateLib (dbusxmlgroup)
                                interfaceoutputs.append (walker.interfaceDeclaration ())
                        else:
                                raise InterfaceNotFoundError ("error: %s is not an interface" % (interface))
                else:
                        raise InterfaceNotFoundError ("error: %s could not be found" % (interface))

        dbusxml = dbusxmlgroup.getInstanceOf ("dbusxml")
        dbusxml ["interfaces"] = interfaceoutputs

        return dbusxml
