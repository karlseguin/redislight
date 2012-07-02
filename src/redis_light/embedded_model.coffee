H = require('./helper')
lingo = require('lingo').en
Model = require('./model')

class EmbeddedModel extends Model
  @belongs_to: (belongs_to) ->
    @_belongs_to = belongs_to
    @_belongs_key = lingo.pluralize(belongs_to)

  @key: (id) -> "#{@_belongs_key}:#{id}:#{@_storage_name}"

  @find:  (parent_id, id, options, callback) ->
    if Array.isArray(id)
      @redis().hmget @key(parent_id), id, @_callback(parent_id, id, options, callback)
    else
      @redis().hget @key(parent_id), id, @_callback(parent_id, id, options, callback)

  @find_all: (parent_id, options, callback) ->
    @redis().hgetall @key(parent_id), @_callback(parent_id, null, options, callback)

  @_callback: (parent_id, item_id, options, callback) ->
    callback = options if options instanceof Function
    (err, data) =>
      return callback(err, data) if err?  || !data?
      if Array.isArray(item_id)
        values = {}
        for value, index in data
          values[item_id[index]] = @_create(parent_id, item_id[index], value, options.raw)
        callback(err, values)
      else if item_id?
        item = @_create(parent_id, item_id, data, options.raw)
        callback(err, item)
      else
        values = {}
        for id, value of data
          values[id] = @_create(parent_id, id, value, options.raw)
        callback(err, values)

  @_create: (parent_id, id, data, raw) ->
    return null unless data?
    id = parseInt(id) if @_auto_id == true
    item = super(id, data, raw)
    item[@_belongs_to] = parent_id
    item

  _belongs_to: -> @.constructor._belongs_to

  _parent_id: -> @[@_belongs_to()]

  _persist: (data, callback) ->
    @redis().hset @_key(@_parent_id()), @.id, data, callback

  constructor: (params = {}, id = null) ->
    super params, id
    belongs_to = @_belongs_to()
    @[belongs_to] = params[belongs_to].id if params[belongs_to]?

module.exports = EmbeddedModel