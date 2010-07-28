from functools import reduce

class ScopedString (object):

        def __init__ (self):
                self._stack = []

        def push (self, frame):
                self._stack.append (frame)

        def pop (self):
                frame = self._stack.pop()
                return frame

        def __str__ (self):
                return '.'.join (self._stack)

class ScopedList (object):
        def __init__ (self, stack=None):
                if stack:
                        self._stack = stack
                else:
                        self._stack = []
                        self.push()

        def push (self):
                self._stack.append ([])

        def pop (self):
                if (len (self._stack) <= 1):
                        raise IndexError ("Attempt to pop global scope")
                self._stack.pop()

        def append (self, val):
                self._stack[-1].append (val)

        def _normalize (self):
                return reduce (lambda x, y: x + y, self._stack, [])

        def __str__ (self):
                return str (self._normalize())

        def __repr__ (self):
                return "ScopedDict(" + repr(self._stack) + ")"

        def __iter__ (self):
                return self._normalize().__iter__()

class ScopedDict (object):

        def __init__ (self, stack=None):
                if stack:
                        self._stack = stack
                else:
                        self._stack = []
                        self.push ()

        def push (self):
                self._stack.insert (0, {})

        def pop (self):
                if (len (self._stack) <= 1):
                        raise IndexError ("Attempt to pop global scope")
                temp = self._stack[0]
                del (self._stack[0])
                return temp

        def _normalize (self):
                normal = {}
                for frame in self._stack:
                        for key, value in frame.items():
                                if key not in normal:
                                        normal[key] = value
                return normal

        def __getitem__ (self, key):
                for frame in self._stack:
                        if key in frame:
                                return frame[key]
                raise KeyError (key)

        def __setitem__ (self, key, value):
                self._stack[0][key] = value

        def __contains__ (self, key):
                for frame in self._stack:
                        if key in frame:
                                return True
                return False

        def __str__ (self):
                return str (self._normalize())

        def __repr__ (self):
                return "ScopedDict(" + repr(self._stack) + ")"

        def __iter__ (self):
                return self._normalize().__iter__()

        def items (self):
                return self._normalize().items()

        def keys (self):
                return self._normalize().keys()

        def values (self):
                return self._normalize().values()
