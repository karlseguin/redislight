helper = require('../helper')
RL = helper.RL
Model = RL.Model

describe 'model find', ->
  beforeEach helper.setup
  afterEach helper.teardown

  it "returns null if the item isn't found", (done) ->
    Model.find '123', (err, found) ->
      expect(err).toBeNull()
      expect(found).toBeNull()
      done()

  it "returns the found item", (done) ->
    RL.Store.redis.set 'fakemodels:9001', RL.Helper.serialize(n: 'leto', i: 9001), ->
      FakeModel.find 9001, (err, found) ->
        expect(err).toBeNull()
        expect(found instanceof FakeModel).toBeTruthy()
        expect(found.id).toEqual(9001)
        expect(found.name).toEqual('leto')
        done()

  it "returns the raw data", (done) ->
    RL.Store.redis.set 'fakemodels:10001', RL.Helper.serialize(n: 'ghanima', i: 10001), ->
      FakeModel.find 10001, {raw: true}, (err, found) ->
        expect(err).toBeNull()
        expect(found instanceof FakeModel).toBeFalsy()
        expect(found.id).toEqual(10001)
        expect(found.name).toEqual('ghanima')
        done()