RL = require('../src/redis_light')
Store = RL.Store

module.exports.RL = RL

module.exports.setup = (done) ->
  Store.initialize {host: 'localhost', port: 6379, database: 5}, ->
    Store.redis.flushdb(done)

module.exports.teardown = (done) ->
  Store.redis.end()
  done()

class FakeModel extends RL.Model
  @properties 'id', 'name'

class FakeEmbeddedModel extends RL.EmbeddedModel
  @belongs_to 'spice'
  @properties 'id', 'name'

class FakeAutoIdModel extends RL.Model
  @auto_generate_id()
  @properties 'name', 'age'

class FakeEmbeddedAutoIdModel extends RL.EmbeddedModel
  @belongs_to 'worm'
  @auto_generate_id()
  @properties 'name', 'age'

module.exports.FakeModel = FakeModel
module.exports.FakeEmbeddedModel = FakeEmbeddedModel
module.exports.FakeAutoIdModel = FakeAutoIdModel
module.exports.FakeEmbeddedAutoIdModel = FakeEmbeddedAutoIdModel