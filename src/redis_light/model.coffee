Store = require('./store')
H = require('./helper')
lingo = require('lingo').en

class Model
  @properties: ->
    @_map = {}
    @_unmap = {}
    @_storage_name = lingo.pluralize(@.name.toLowerCase())
    for name in arguments
      alias = H.alias(name, @_unmap)
      @_map[name] = alias
      @_unmap[alias] = name

  @auto_generate_id: -> @_auto_id = true

  @redis: -> Store.redis

  @key: (id) -> "#{@_storage_name}:#{id}"

  @find: (id, options, callback) ->
    callback = @_callback(id, options, callback)
    @redis().get @key(id), callback

  @_callback: (id, options, callback) ->
    callback = options if options instanceof Function
    (err, data) =>
      return callback(err, data) if err? || !data?
      callback(err, @_create(id, data, options.raw))

  @_create: (id, data, raw) ->
    data = H.deserialize(data)
    unmapped = {}
    unmapped[name] = data[alias] for alias, name of @_unmap
    return new @(unmapped, id) if !raw

    unmapped.id = id unless unmapped.id?
    unmapped

  _storage_name: => @.constructor._storage_name
  _key: (id) => @.constructor.key(id)

  constructor: (params = {}, id = null) ->
    @[name] = params[name] for name of @.constructor._map when params[name]?
    @.id = id if id? && !@.id?

  redis: -> Store.redis

  save: (callback) =>
    if !@.id? && @.constructor._auto_id == true
      H.id @_storage_name(), (err, id) =>
        return callback(err) if err?
        @.id = id
        @save(callback)
      return
    return callback('missing id') if !@.id?

    @_persist @save_data(), callback
    return @

  save_data: =>
    data = {}
    data[alias] = @[name] for name, alias of @.constructor._map when @[name]?
    H.serialize(data)

  _persist: (data, callback) ->
    @redis().set @_key(@.id), data, callback

module.exports = Model

# class ChildModel

  # @extend: (target) ->
  #   target.key = @key
  #   target.find = @find
  #   target.find_all = @find_all

  # @find: (parent_id, id, callback) ->

  # @find_all: (parent_id, callback) ->

  # @key: (id) -> "#{@_belongs_to}:#{id}:#{@_storage_name}"
    # if @_belongs_to?
    #   if typeof id == 'function'
    #     Store.redis.hgetall @key(parent_id), callback
    #   else
    #     Store.redis.hget @key(parent_id), id, callback
    # else
    #   k

    # @callback: (parent_id, id, callback) ->
    # callback = id unless callback?

    # (err, data) =>
    #   return callback(err, data) if err?

    #   if @_belongs_to?
    #     if typeof id == 'function'
    #       found = []
    #       for key, d of data
    #         e = H.create(@, key, d)
    #         e[@_belongs_to] = parent_id
    #         found.push(e)
    #       callback(err, found)
    #     else
    #       e = H.create(@, id, data)
    #       e[@_belongs_to] = parent_id
    #       callback(err, e)
    #   else
    #     e = H.create(@, parent_id, data)
    #     callback(err, e)



# Store = require('./store')
# H = require('./helper')
# types = require('./types')
# lingo = require('lingo').en

# class Model
#   @properties: (properties) ->
#     @_map = {}
#     @_unmap = {}
#     @_properties = {}
#     @_storage_name = lingo.pluralize(@.name.toLowerCase())

#     for name, type of properties
#       alias = H.alias(name, @_unmap)
#       @_properties[name] = type
#       @_map[name] = alias
#       @_unmap[alias] = name

#   @belongs_to: (_belongs_to) ->
#     @_belongs_to = _belongs_to
#     ChildModel.extend(@)

#   @auto_generate_id: -> @_auto_id = true

#   @key: (id) -> "#{@_storage_name}:#{id}"

#   @find: (id, callback) ->
#     callback = @callback(id, callback)
#     Store.redis.get @key(parent_id), callback

#   @callback: (id, callback) ->
#     (err, data) =>
#       return callback(err, data) if err?
#       callback(err, H.create(@, id, data))

#   constructor: (params) ->
#     for name, type of @.constructor._properties when params[name]?
#       value = params[name]
#       if type == types.integer
#         value = parseInt(value)
#         continue if isNaN(value)
#       @[name] = value

#     belongs_to = @.constructor._belongs_to
#     @[belongs_to] = params[belongs_to].id if belongs_to? && params[belongs_to]?


#   _storage_name: => @.constructor._storage_name
#   _key: (id) => @.constructor.key(id)

#   save: (callback) =>
#     if !@.id? && @.constructor._auto_id == true
#       H.id @_storage_name(), (err, id) =>
#         return callback(err) if err?
#         @.id = id
#         @save(callback)
#       return

#     return callback('missing id') if !@.id?

#     doc = {}
#     doc[alias] = @[name] for name, alias of @.constructor._map when @[name]?
#     doc = H.serialize(doc)

#     belongs_to_name = @.constructor._belongs_to
#     if belongs_to_name?
#       belongs_to = @[belongs_to_name]
#       Store.redis.hset @_key(belongs_to), @.id, doc, callback
#     else
#       Store.redis.set @_key(@.id), doc, callback

# # class ChildModel

#   @extend: (target) ->
#     target.key = @key
#     target.find = @find
#     target.find_all = @find_all

#   @find: (parent_id, id, callback) ->

#   @find_all: (parent_id, callback) ->

#   @key: (id) -> "#{@_belongs_to}:#{id}:#{@_storage_name}"
#     # if @_belongs_to?
#     #   if typeof id == 'function'
#     #     Store.redis.hgetall @key(parent_id), callback
#     #   else
#     #     Store.redis.hget @key(parent_id), id, callback
#     # else
#     #   k

#     # @callback: (parent_id, id, callback) ->
#     # callback = id unless callback?

#     # (err, data) =>
#     #   return callback(err, data) if err?

#     #   if @_belongs_to?
#     #     if typeof id == 'function'
#     #       found = []
#     #       for key, d of data
#     #         e = H.create(@, key, d)
#     #         e[@_belongs_to] = parent_id
#     #         found.push(e)
#     #       callback(err, found)
#     #     else
#     #       e = H.create(@, id, data)
#     #       e[@_belongs_to] = parent_id
#     #       callback(err, e)
#     #   else
#     #     e = H.create(@, parent_id, data)
#     #     callback(err, e)

# module.exports = Model