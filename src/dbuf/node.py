from antlr3.tree import CommonTree as _CommonTree
from antlr3.tree import CommonTreeAdaptor as _CommonTreeAdaptor
from antlr3.tree import CommonTreeNodeStream as _CommonTreeNodeStream

import templates
import stringtemplate3
from dbufsignature import dbufsignature

from StringIO import StringIO

class DbufTreeAdaptor (_CommonTreeAdaptor):
        def createWithPayload (self, payload):
                return DbufTree (payload)

class DbufTree (_CommonTree):

        joined = None
        canonical = None
        fqn = None

        # The 'tokens' attribute is filled in for all symbol definition nodes such as
        # interfaces, structs and enums.
        #
        # The 'tokens' attribute is a token stream that is used for error returns, typing
        # and text information when parsing in antlr. It is so that each symbol definition
        # tree node has the information readily available to become the root node for an
        # AST re-write or template outputting phase.
        tokens = None

        # They 'symbol' attribute is filled in by the linker.
        #
        # It is only available for type identifier nodes and points to the tree node of
        # the type declaration for the type identified.
        #
        # This joins together a types use with its definition and creates non-hierarchal
        # links within the AST tree or trees.
        symbol = None

        # TODO Surely the signature is only available on a certain type of node also
        # Need to throw exceptions here if an access attempt is made that does
        # not make sense.
        _signature = None
        @property
        def signature (self):
                if not self._signature:
                        templategroup = stringtemplate3.StringTemplateGroup (file=StringIO (templates.signature))

                        nodes = _CommonTreeNodeStream (self)
                        nodes.setTokenStream (self.tokens)
                        walker = dbufsignature (nodes)
                        walker.setTemplateLib (templategroup)
                        self._signature = walker.signature().toString()
                return self._signature
