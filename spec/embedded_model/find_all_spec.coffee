helper = require('../helper')
RL = helper.RL
FakeEmbeddedModel = helper.FakeEmbeddedModel
FakeEmbeddedAutoIdModel = helper.FakeEmbeddedAutoIdModel

describe 'embedded model find_all', ->
  beforeEach helper.setup
  afterEach helper.teardown

  it "returns empty if the item isn't found", (done) ->
    FakeEmbeddedModel.find_all 'parent_id', (err, found) ->
      expect(err).toBeNull()
      expect(found).toEqual([])
      done()

  it "returns the found items", (done) ->
    RL.Store.redis.hset 'worms:9002:fakeembeddedautoidmodels', 93, RL.Helper.serialize(n: 'leto'), (err, x) ->
      RL.Store.redis.hset 'worms:9002:fakeembeddedautoidmodels', 94, RL.Helper.serialize(n: 'ghanima'), (err, x) ->
        FakeEmbeddedAutoIdModel.find_all 9002, (err, found) ->
          expect(err).toBeNull()
          expect(Object.keys(found).length).toEqual(2)
          expect(found[93] instanceof FakeEmbeddedAutoIdModel).toBeTruthy()
          expect(found[93].id).toEqual(93)
          expect(found[93].worm).toEqual(9002)
          expect(found[93].name).toEqual('leto')
          expect(found[94] instanceof FakeEmbeddedAutoIdModel).toBeTruthy()
          expect(found[94].id).toEqual(94)
          expect(found[94].worm).toEqual(9002 )
          expect(found[94 ].name).toEqual('ghanima')
          done()

  it "returns the raw data", (done) ->
    RL.Store.redis.hset 'spices:abc:fakeembeddedmodels', 304, RL.Helper.serialize(n: 'leto', i: 304), (err, x) ->
      RL.Store.redis.hset 'spices:abc:fakeembeddedmodels', 306, RL.Helper.serialize(n: 'ghanima', i: 306), (err, x) ->
        FakeEmbeddedModel.find_all 'abc', {raw: true}, (err, found) ->
          expect(err).toBeNull()
          expect(Object.keys(found).length).toEqual(2)
          expect(found[304] instanceof FakeEmbeddedModel).toBeFalsy()
          expect(found[304].id).toEqual(304)
          expect(found[304].spice).toEqual('abc')
          expect(found[304].name).toEqual('leto')
          expect(found[306] instanceof FakeEmbeddedModel).toBeFalsy()
          expect(found[306].id).toEqual(306)
          expect(found[306].spice).toEqual('abc' )
          expect(found[306].name).toEqual('ghanima')
          done()