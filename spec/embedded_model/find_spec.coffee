helper = require('../helper')
RL = helper.RL
FakeEmbeddedModel = helper.FakeEmbeddedModel

describe 'embedded model find', ->
  beforeEach helper.setup
  afterEach helper.teardown

  it "returns null if the item isn't found", (done) ->
    FakeEmbeddedModel.find 'parent_id', [123, 334], (err, found) ->
      expect(err).toBeNull()
      expect(found).toEqual({123: null, 334: null})
      done()

  it "returns the found items", (done) ->
    RL.Store.redis.hmset 'spices:9001:fakeembeddedmodels', {93: RL.Helper.serialize(n: 'leto'), 94: RL.Helper.serialize(n: 'ghanima'), 95: RL.Helper.serialize(n: 'duncan')}, (err, x) ->
      FakeEmbeddedModel.find 9001, [93, 94], (err, found) ->
        expect(Object.keys(found).length).toEqual(2)
        expect(found[93].id).toEqual(93)
        expect(found[93].spice).toEqual(9001)
        expect(found[93].name).toEqual('leto')
        expect(found[94].id).toEqual(94)
        expect(found[94].spice).toEqual(9001)
        expect(found[94].name).toEqual('ghanima')
        done()

  it "returns the raw data", (done) ->
    RL.Store.redis.hmset 'spices:323:fakeembeddedmodels', {'abc': RL.Helper.serialize(n: 'ghanima')}, (err, x) ->
      FakeEmbeddedModel.find 323, ['abc'], {raw: true}, (err, found) ->
        expect(err).toBeNull()
        expect(found['abc'] instanceof FakeEmbeddedModel).toBeFalsy()
        expect(found['abc'].id).toEqual('abc')
        expect(found['abc'].spice).toEqual(323)
        expect(found['abc'].name).toEqual('ghanima')
        done()