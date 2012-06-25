helper = require('../helper')
RL = helper.RL
FakeEmbeddedModel = helper.FakeEmbeddedModel
FakeEmbeddedAutoIdModel = helper.FakeEmbeddedAutoIdModel

describe 'embedded model save', ->
  beforeEach helper.setup
  afterEach helper.teardown

  it "returns error if id isn't set", (done) ->
    new FakeEmbeddedModel(spice: {id: 1}).save (err) ->
      expect(err).toEqual("missing id")
      done()

  it "saves the object with an explicit id", (done) ->
    new FakeEmbeddedModel(name: 'fm', id: 9392, spice: {id: 3}).save (err, res) ->
      expect(err).toBeNull()
      expect(res).toEqual(1)
      RL.Store.redis.hget 'spices:3:fakeembeddedmodels', 9392, (err, data) ->
        expect(RL.Helper.deserialize(data)).toEqual(n: 'fm', i: 9392)
        done()

  it "saves the object with a generated id", (done) ->
    m = new FakeEmbeddedAutoIdModel(name: 'fm', worm: {id: 3932})
    m.save (err, res) ->
      expect(err).toBeNull()
      expect(res).toEqual(1)
      expect(m.id).toEqual(1)
      RL.Store.redis.hget 'worms:3932:fakeembeddedautoidmodels', 1, (err, data) ->
        expect(RL.Helper.deserialize(data)).toEqual(n: 'fm')
        done()

  it "increments the id per type", (done) ->
    m1 = new FakeEmbeddedAutoIdModel(name: 'm1', worm: {id: 3932})
    m2 = new FakeEmbeddedAutoIdModel(name: 'm2', worm: {id: 3932})
    m3 = new FakeEmbeddedAutoIdModel(name: 'm3', worm: {id: 3932})
    m1.save -> m2.save -> m3.save ->
      expect(m1.id).toEqual(1)
      expect(m2.id).toEqual(2)
      expect(m3.id).toEqual(3)
      done()