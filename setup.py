import os
import sys
import glob
import subprocess
import unittest

from distutils.core import setup, Command
from distutils.command.build import build
from distutils.command.clean import clean
from distutils.dir_util import copy_tree, remove_tree

ANTLR_JAR                     = 'resources/antlr-3.1.2.jar'

GRAMMAR_FILES       = glob.glob ('src/grammar/*.g')
GRAMMAR_CLEAN_FILES = glob.glob ('src/dbuf/dbuf*.py') + glob.glob ('src/dbuf/*.tokens')

class check (Command):
        description = "Runs the functional tests"
        user_options = []

        def initialize_options(self):
                pass

        def finalize_options(self):
                pass

        def run(self):
                sys.path.append (os.getcwd() + '/test')
                sys.path.append (os.getcwd() + '/src')

                suite = unittest.TestLoader().loadTestsFromNames (['parsing', 'signature', 'resolution', 'dbusxml'])
                unittest.TextTestRunner (verbosity=2).run (suite)

class extended_build (build):

        def _antlr_compile (self):
                classpath = os.path.abspath (ANTLR_JAR)
                args = ['java', '-classpath', classpath, 'org.antlr.Tool', '-fo', 'src/dbuf']
                args.extend (GRAMMAR_FILES)
                p = subprocess.Popen(args)
                p.wait()

        def run (self):
                #Compile the antlr files
                self._antlr_compile ()
                return build.run (self)

class extended_clean (clean):

        def run (self):
                #Remove built grammar sources
                for fname in GRAMMAR_CLEAN_FILES:
                        os.remove (fname)
                #Remove *.pyc files as testing will generate these
                for fname in glob.glob ('src/dbuf/*.pyc'):
                        os.remove (fname)
                for fname in glob.glob ('src/dbuf/templates/*.pyc'):
                        os.remove (fname)
                for fname in glob.glob ('test/*.pyc'):
                        os.remove (fname)
                return clean.run (self)

setup (
        name = 'dbuf',
        version = '0.1',
        cmdclass = {'build': extended_build, 'clean': extended_clean, 'check': check},
        package_dir = {'': 'src'},
        packages = ['dbuf', 'dbuf.templates'],
        scripts = ['src/dbuftodbusxml'],
      )
