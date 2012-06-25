mp = require('msgpack')
Store = require('./store')

class Helper
  @alias: (name, existing) ->
    for char, index in name
      alias = name[0..index]
      return alias unless existing[alias]?
    name

  @id: (name, callback) -> Store.redis.hincrby '_rl_id_gen', name, 1, callback

  @serialize: (data) -> mp.pack(data)
  @deserialize: (data) -> mp.unpack(data)

module.exports = Helper