redis = require('redis')

class Store
  @initialize: (config, callback) ->
    @redis = redis.createClient(config.port, config.host, return_buffers: true)
    @redis.select(config.database, callback)

module.exports = Store