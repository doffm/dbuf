import sys
import unittest

from dbuf import compile

class TestResolution (unittest.TestCase):

        def setUp (self):
                self.syms = compile (["test/data/resolution.dbuf"])

        def test_same (self):
                self.assertEqual (self.syms['org.test.dbuf.same.Bar'].signature, u'(u)')

        def test_sub (self):
                self.assertEqual (self.syms['org.test.dbuf.sub.Bar'].signature, u'(i)')

        def test_using_ancestor (self):
                self.assertEqual (self.syms['org.test.dbuf.us.ancestor.sub.Bar'].signature, u'(q)')

        def test_using_separate (self):
                self.assertEqual (self.syms['org.test.dbuf.us.separate.b.Bar'].signature, u'(n)')

        def test_alias_ancestor (self):
                self.assertEqual (self.syms['org.test.dbuf.al.ancestor.sub.Bar'].signature, u'(t)')

        def test_alias_separate (self):
                self.assertEqual (self.syms['org.test.dbuf.al.separate.b.Bar'].signature, u'(x)')

        def test_fqn (self):
                self.assertEqual (self.syms['org.test.dbuf.fqn.b.Bar'].signature, u'(y)')

if __name__ == '__main__':
        unittest.main ()
