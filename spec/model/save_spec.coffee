helper = require('../helper')
RL = helper.RL
Model = RL.Model

describe 'model save', ->
  beforeEach helper.setup
  afterEach helper.teardown

  it "returns error if id isn't set", (done) ->
    new Model().save (err) ->
      expect(err).toEqual("missing id")
      done()

  it "saves the object with an explicit id", (done) ->
    new FakeModel(name: 'fm', id: 9392).save (err, res) ->
      expect(err).toBeNull()
      expect(res).toEqual('OK')
      RL.Store.redis.get 'fakemodels:9392', (err, data) ->
        expect(RL.Helper.deserialize(data)).toEqual(n: 'fm', i: 9392)
        done()

  it "saves the object with a generated id", (done) ->
    m = new FakeAutoIdModel(name: 'fm')
    m.save (err, res) ->
      expect(err).toBeNull()
      expect(res).toEqual('OK')
      expect(m.id).toEqual(1)
      RL.Store.redis.get 'fakeautoidmodels:1', (err, data) ->
        expect(RL.Helper.deserialize(data)).toEqual(n: 'fm')
        done()

  it "increments the id per type", (done) ->
    m1 = new FakeAutoIdModel(name: 'm1')
    m2 = new FakeAutoIdModel(name: 'm2')
    m3 = new FakeAutoIdModel(name: 'm3')
    m1.save -> m2.save -> m3.save ->
      expect(m1.id).toEqual(1)
      expect(m2.id).toEqual(2)
      expect(m3.id).toEqual(3)
      done()