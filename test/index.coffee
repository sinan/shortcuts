should    = require 'should'
Shortcuts = require '../index'

describe 'Shortcuts', ->

  it 'should get', ->

    s = new Shortcuts
      x: [
        { name: 'foo' }
      ]
      y: [
        { name: 'bar' }
        { name: 'baz' }
      ]

    s.get('y').name.should.eql 'y'
    s.get('x').name.should.eql 'x'
    s.get('y', 'baz').name.should.eql 'baz'
    z = s.get 'z'
    (z is undefined).should.eql yes
    should.doesNotThrow s.get.bind(s, 'z', 'qux')

  it 'should update num of listeners', ->

    s = new Shortcuts
      x: []
      y: []

    s._numListeners.x.should.eql 0
    s._numListeners.y.should.eql 0

    s.on 'key:x', ->
    s._numListeners.x.should.eql 1
    s._numListeners.y.should.eql 0

    s.once 'key:x', ->
    s._numListeners.x.should.eql 2

    s.removeAllListeners 'key:x'
    s._numListeners.x.should.eql 0

  it 'removeAllListeners should always expect a type', ->

    s = new Shortcuts
    should.throws s.removeAllListeners

  it 'should bind/unbind keys', ->
    
    s = new Shortcuts
      x: [
        { name: 'a', binding: [ ['z'], ['x', 'y'] ] },
        { name: 'b', binding: [ null, ['a+b'] ] }
      ],
      y: [
        { name: 'c', binding: [ null, ['a+b'] ] }
      ]

    times = 0
    cb = (n, e) ->
      if times is 0
        if n is 'x'
          e.sequence.should.eql 'y'
          e.collection.name.should.eql 'x'
          e.model.name.should.eql 'a'
        if n is 'y'
          e.sequence.should.eql 'a+b'
          e.collection.name.should.eql 'y'
          e.model.name.should.eql 'c'
      times++

    cbx = cb.bind cb, 'x'
    cby = cb.bind cb, 'y'

    s.on 'key:x', cbx

    Object.keys(s._listeners).should.have.lengthOf 1

    s.on 'key:y', cby
    Object.keys(s._listeners).should.have.lengthOf 2

    s._listeners.should.have.ownProperty 'x'
    s._listeners.should.have.ownProperty 'y'
    s._listeners.x.should.have.ownProperty 'a'
    s._listeners.x.should.have.ownProperty 'b'
    s._listeners.x.a.should.be.Array
    s._listeners.x.a.should.have.lengthOf 2
    s._listeners.x.a[0].sequence.should.eql 'x'

    Mousetrap.trigger 'y'
    Mousetrap.trigger 'y'
    times.should.eql 2

    Mousetrap.trigger 'a+b'
    times.should.eql 3

    s.removeListener 'key:x', cbx

    Object.keys(s._listeners).should.have.lengthOf 1

    Mousetrap.trigger 'y'
    times.should.eql 3

    Mousetrap.trigger 'a+b'
    times.should.eql 4

    s.removeAllListeners 'key:y'
    Mousetrap.trigger 'a+b'
    times.should.eql 4

    Object.keys(s._listeners).should.have.lengthOf 0

    times = 0
    s._numListeners.x.should.eql 0
    s.once 'key:x', cbx
    s._numListeners.x.should.eql 1
    Object.keys(s._listeners).should.have.lengthOf 1
    Mousetrap.trigger 'y'
    times.should.eql 1
    Object.keys(s._listeners).should.have.lengthOf 0
    Mousetrap.trigger 'y'
    times.should.eql 1
