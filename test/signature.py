import sys
import unittest

from dbuf import compile

class TestSignature (unittest.TestCase):

        def test_signature (self):
                checktable = {'org.dbuf.test.Signature.BasicTypes'     : '(ybnqiuxtdsogv)',
                              'org.dbuf.test.Signature.ArrayTypes'     : '(yay)',
                              'org.dbuf.test.Signature.ByteEnum'       : 'y',
                              'org.dbuf.test.Signature.Int16Enum'      : 'n',
                              'org.dbuf.test.Signature.Int32Enum'      : 'i',
                              'org.dbuf.test.Signature.Int64Enum'      : 'x',
                              'org.dbuf.test.Signature.SimpleStruct'   : '(yn)',
                              'org.dbuf.test.Signature.CompoundStruct' : '((yn)a(yn))',
                              'org.dbuf.test.Signature.DictStruct'     : '(a{n((yn)a(yn))})',
                              'org.dbuf.test.Signature.DictDef'        : 'a{nn}',
                              'org.dbuf.test.Signature.CompoundDef'    : 'aa((yn)a(yn))',
                              'org.dbuf.test.Signature.UseDefStruct'   : '(aa((yn)a(yn)))',
                     }

                tab = compile (["test/data/signature.dbuf"])

                for (identifier, expected) in checktable.items():
                        typ = tab[identifier]
                        self.assertEqual (typ.signature, expected)

if __name__ == '__main__':
        unittest.main ()
