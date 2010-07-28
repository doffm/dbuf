import sys
import antlr3
import stringtemplate3
from StringIO import StringIO

from dbuf import *
import dbuf.templates

def getTestOutput (fname):
        templates = stringtemplate3.StringTemplateGroup (file=StringIO(dbuf.templates.testxml))

        defined, root, tokens = parse (fname)

        # Invoke tree walker to generate template output
        nodes = antlr3.tree.CommonTreeNodeStream (root)
        nodes.setTokenStream (tokens)
        walker = dbufoutput (nodes)
        walker.setTemplateLib (templates)
        res = walker.idl ()

        return res.toString ()

def main (argv):
        print getTestOutput (argv[1])

if __name__ == "__main__":
        sys.exit (main (sys.argv))
