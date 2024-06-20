import operator

class StreamError(Exception):
    pass

class Stream(object):

    def __init__(self, head=None, tail_promise=None):
        self.head_value = head
        if tail_promise is None:
            self.tail_promise = lambda: Stream()
        else:
            self.tail_promise = tail_promise

    def empty(self):
        return self.head_value is None

    def head(self):
        if self.empty():
            raise StreamError('cannot get the head of an empty stream')
        return self.head_value

    def tail(self):
        if self.empty():
            raise StreamError('cannot get the tail of an empty stream')
        return self.tail_promise()

    def __getitem__(self, key):
        if isinstance(key, int):
            if self.empty():
                raise StreamError('cannot get an item of an empty stream')
            this = self
            while key:
                key -= 1
                try:
                    this = this.tail()
                except StreamError:
                    raise IndexError('stream index out of range')
            try:
                return this.head()
            except StreamError:
                raise IndexError('stream index out of range')
        elif isinstance(key, slice):
            if self.empty():
                return self
            if not key.stop:
                return Stream()
            this = self
            return Stream(self.head(),
                          lambda: this.tail()[:key.stop - 1])

    def item(self, n):
        return self[n]

    def take(self, how_many):
        return self[:how_many]

    def length(self):
        this = self
        n = 0
        while not this.empty():
            n += 1
            this = this.tail()
        return n

    __len__ = length

    def zip(self, f, s):
        if self.empty():
            return s
        if s.empty():
            return self
        this = self
        return Stream(f(s.head(), self.head()),
                      lambda: this.tail().zip(f, s.tail()))

    def add(self, s):
        return self.zip(operator.add, s)

    def map(self, f):
        if self.empty():
            return self
        this = self
        return Stream(f(self.head()),
                      lambda: this.tail().map(f))

    def reduce(self, aggregator, initial):
        if self.empty():
            return initial
        return self.tail().reduce(aggregator,
                                  aggregator(initial, self.head()))

    def sum(self):
        return self.reduce(operator.add, 0)

    def force(self):
        this = self
        while not this.empty():
            this = this.tail()
        
    def walk(self, f):
        def inner_walk(x):
            f(x)
            return x
        self.map(inner_walk).force()

    def scale(self, factor):
        return self.map(lambda x: factor * x)

    def filter(self, f):
        if self.empty():
            return self
        h = self.head()
        t = self.tail()
        if f(h):
            return Stream(h, lambda: t.filter(f))
        return t.filter(f)

    def drop(self, n):
        this = self
        while n > 0:
            n -= 1
            if this.empty():
                return Stream()
            this = this.tail()
        return Stream(this.head_value, this.tail_promise)

    def member(self, item):
        this = self
        while not this.empty():
            if this.head() == item:
                return True
            this = this.tail()
        return False

    __contains__ = member

    def output(self, n=None):
        if n is None:
            target = self
        else:
            target = self[:n]
        result = []
        target.walk(lambda x: result.append(str(x)))
        return 'Stream(%s)' % ', '.join(result)

    def __repr__(self):
        return self.output()

    @classmethod
    def make_ones(cls):
        return cls(1, cls.make_ones)

    @classmethod
    def make_natural_numbers(cls):
        return cls(1, lambda: cls.make_natural_numbers().add(cls.make_ones()))

    @classmethod
    def make(cls, *args):
        if not args:
            return cls()
        return cls(args[0], lambda: cls.make(*args[1:]))

    @classmethod
    def range(cls, low=1, high=None):
        if low == high:
            return cls.make(low)
        return cls(low, lambda: cls.range(low + 1, high))
