helper = require('../helper')
RL = helper.RL
FakeEmbeddedModel = helper.FakeEmbeddedModel

describe 'embedded model find one', ->
  beforeEach helper.setup
  afterEach helper.teardown

  it "returns null if the item isn't found", (done) ->
    FakeEmbeddedModel.find 'parent_id', 123, (err, found) ->
      expect(err).toBeNull()
      expect(found).toBeNull()
      done()

  it "returns the found item", (done) ->
    RL.Store.redis.hset 'spices:9001:fakeembeddedmodels', 93, RL.Helper.serialize(n: 'leto'), (err, x) ->
      FakeEmbeddedModel.find 9001, 93, (err, found) ->
        expect(err).toBeNull()
        expect(found instanceof FakeEmbeddedModel).toBeTruthy()
        expect(found.id).toEqual(93)
        expect(found.spice).toEqual(9001)
        expect(found.name).toEqual('leto')
        done()

  it "returns the raw data", (done) ->
    RL.Store.redis.hset 'spices:323:fakeembeddedmodels', 'abc', RL.Helper.serialize(n: 'ghanima'), (err, x) ->
      FakeEmbeddedModel.find 323, 'abc', {raw: true}, (err, found) ->
        expect(err).toBeNull()
        expect(found instanceof FakeEmbeddedModel).toBeFalsy()
        expect(found.id).toEqual('abc')
        expect(found.spice).toEqual(323)
        expect(found.name).toEqual('ghanima')
        done()