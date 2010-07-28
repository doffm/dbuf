import sys
import unittest
import glob

from xml.dom.minidom import parseString, parse

from dbuf import output

class TestDBusXML (unittest.TestCase):

        def test_atspi (self):
                filenames = glob.glob ("test/data/dbusxml/*.dbuf")

                expected = parse ("test/data/dbusxml/result.xml")
                result = parseString (output (filenames).toString ())

                self.assertEqual (expected.toxml(), result.toxml())

if __name__ == '__main__':
        unittest.main ()
