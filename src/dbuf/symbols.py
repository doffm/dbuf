_ID_SEPARATOR = '.'

def makeJoined (first, rest):
        """
        The using alias' are not used for namespace and interface definitions.

        This function joins the parts of the identifer for namespaces and interfaces.
        """
        if rest is None:
                rest = []
        first_s = first.text
        rest_s = [token.text for token in rest]
        return _ID_SEPARATOR.join ([first_s] + rest_s)

def makeCanonical (alias, first, rest):
        """
        Gets the canonical name for a symbol identifier.

        This joins all the parts of the identifier in-to one
        string and expands any aliases on the first part of the
        identifier.
        """
        if rest is None:
                rest = []
        first_s = first.text
        rest_s = [token.text for token in rest]
        if first_s in alias:
                return _ID_SEPARATOR.join ([alias[first_s]] + rest_s)
        else:
                return _ID_SEPARATOR.join ([first_s] + rest_s)

def makeFQN (namespace, identifier):
        """
        Gets the fully-qualified-name of the identifier.

        This adds the current namespace to the beginning of
        the identifer to get its name in the global namespace.
        """
        if (str(namespace)):
                return _ID_SEPARATOR.join ([str(namespace), identifier])
        else:
                return identifier

class SymbolStash (dict):

        def __init__ (self):
                dict.__init__ (self)

        def define (self, namespace, identifier, node):
                fqn = makeFQN (namespace, identifier)
                node.fqn = fqn
                self[makeFQN (namespace, identifier)] = node

class LinkerError (Exception):
        def __init__ (self, identifier, msg=None):
                self.identifier = identifier
                self.message = msg
                Exception.__init__(self, msg)

        def _get_message(self):
                return self._message
        def _set_message(self, message):
                self._message = message
        message = property(_get_message, _set_message)

class SymbolNotFoundError (LinkerError):
        def __init__ (self, identifier, tree):
                self.tree = tree
                msg = "The symbol '%s' could not be found. Symbol used on line %d of %s." % \
                      (identifier, tree.getLine(), tree.token.input.getSourceName())
                LinkerError.__init__ (self, identifier, msg)

class MultipleDefinitionsError (LinkerError):
        def __init__ (self, identifier, first, second):
                self.first = first
                self.second = second
                msg = "The symbol '%s' is already defined. First use on line %d of %s, defined again on line %d of %s." % \
                      (identifier,
                       first.line(),
                       first.token.input.getSourceName(),
                       second.line(),
                       second.token.input.getSourceName())
                LinkerError.__init__ (self, identifier, msg)

class SymbolTable (dict):

        def __init__ (self):
                dict.__init__ (self)

        def resolve (self, tree, directive, namespace, identifier):
                """
                Resolves a symbol, returning a link to the tree node where a type is defined.

                tree - The tree node where the type is used. The type identifier node. Used for error reporting.
                directive - A scoped dict containing all the using directives to find what symbols have
                            been imported up to this point.
                namespace - The current namespace.
                identifier - The name of the type. The type identifier.
                """
                # for each using-directive:
                #        Check if the name exists in the using-directive namespace, if-so return the symbol.
                for d in directive:
                        n = makeFQN (d, identifier)
                        if n in self:
                                return self[n]

                # Check if the name exists within the namespace, if-so return the symbol.
                n = makeFQN (namespace, identifier)
                if n in self:
                        return self[n]

                # Check if the name is a FQN (From the root namespace). If-so return the symbol.
                # TODO How do we access a FQN from the root that has an equivalent within this namespace?
                #
                # e.g
                #        namespace Foobar.Foo {
                #                struct Bar {}
                #        }
                #
                #        namespace Barfoo {
                #                namespace Foobar.Foo {
                #                        struct Bar {}
                #                }
                #
                #                /* How do we make this access the *Other* Foobar.Foo.Bar? */
                #                struct Bleugh {Foobar.Foo.Bar boo}
                #        }
                if identifier in self:
                        return self[identifier]

                # Throw a linker error if a symbol is not found.
                raise SymbolNotFoundError (identifier, tree)

        def addModuleSymbols (self, stash):
                """
                Adds a set of symbols defined in a single module to this symbol table.
                """
                for (identifier, tree) in stash.items():
                        if identifier in self:
                                raise MultipleDefinitionsError (identifier, self[identifier], tree)
                        else:
                                self[identifier] = tree
