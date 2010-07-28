import os.path
import unittest
import glob

from xml.dom.minidom import parseString, parse

from util import getTestOutput

class TestParsingMeta(type):
        def __new__(meta, *args, **kwargs):
                cls = type.__new__(meta, *args, **kwargs)

                test_parse_files = glob.glob ("test/data/parsing/*.dbuf")

                def make_test (fname):
                        def new_test (self):
                                name, ext = os.path.splitext (fname)
                                expected = parse (name + '.xml')
                                result = parseString (getTestOutput (fname))

                                self.assertEqual (expected.toxml(), result.toxml())

                        return new_test

                for fname in test_parse_files:
                        head, tail = os.path.split (fname)
                        name, rest = os.path.splitext (tail)
                        name = 'test_parse_%s' % name
                        setattr(cls, name, make_test (fname))

                return cls

class TestParsing (unittest.TestCase):

        __metaclass__ = TestParsingMeta

if __name__ == '__main__':
        unittest.main ()
