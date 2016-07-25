Crypto = require 'crypto'
Redis = require 'redis'

SEPARATOR = ":"
DEFAULT_IN_FIRST = true
DEFAULT_AUTO_HASH = true

FUNC_HASHING = (key) ->
  alg = Crypto.createHash "md5"
  alg.update key
  return alg.digest "hex"

FILTERS =
  eq: (key, value) ->
    return (rec) ->
      return rec[key]? and rec[key] is value

  and: (args) ->
    filters = arguments
    return (rec) ->
      for filter in filters
        unless filter rec then return false
      return true

  or: (args) ->
    filters = arguments
    return (rec) ->
      for filter in filters
        if filter rec then return true
      return false


class RecordList
  @filters: FILTERS

  constructor: (recordStringArray) ->
    this.list = recordStringArray

  filter: (func, toArray) ->
    result = []
    for recs in this.list
      rec = JSON.parse recs
      if !func? or func rec
        result.push if toArray then rec else recs
    return if toArray then result else new RecordList result

  each: (func, filter) ->
    for recs in this.list
      rec = JSON.parse recs
      if !filter? or filter rec
        func rec

  toArray: (rev) ->
    r =
      start: if rev then this.list.length-1 else 0
      end: if rev then 0 else this.list.length-1
    array = []
    for i in [r.start..r.end]
      array.push JSON.parse this.list[i]
    return array

  length: () ->
    return this.list.length


class RedisKeyTable
  @hashing: FUNC_HASHING
  @filters: FILTERS

  @createClient: (dbname, colname, port, host, opt) ->
    client = Redis.createClient port, host, opt
    return new RedisKeyTable client, dbname, colname

  @cloneClient: (dbc, dbname, colname) ->
    client = dbc.client ? dbc
    return new RedisKeyTable client, dbname, colname

  constructor: (client, dbname, colname) ->
    this.client = client
    this.dbname = dbname
    this.colname = colname
    this.inFirst = DEFAULT_IN_FIRST
    this.autoHash = DEFAULT_AUTO_HASH

  redisKey: () ->
    return "#{this.dbname}#{SEPARATOR}#{this.colname}"

  redisTableKey: (tableKey, all) ->
    hkey = if all then "*" else
      if this.autoHash then RedisKeyTable.hashing tableKey else tableKey
    return "#{this.redisKey()}#{SEPARATOR}#{hkey}"

  get: (key, callback) ->
    this.client.lrange this.redisTableKey(key), 0, -1, (err, res) ->
      if err then callback err, null; return
      callback err, new RecordList res

  range: (key, s, e, callback) ->
    this.client.lrange this.redisTableKey(key), s, e, (err, res) ->
      if err then callback err, null; return
      callback err, new RecordList res

  trim: (key, s, e, callback) ->
    this.client.ltrim this.redisTableKey(key), s, e, callback

  push: (key, val, callback) ->
    record = JSON.stringify val
    if this.inFirst
      this.client.lpush this.redisTableKey(key), record, callback
    else
      this.client.rpush this.redisTableKey(key), record, callback

  shift: (key, callback) ->
    if this.inFirst
      this.client.rpop this.redisTableKey(key), callback
    else
      this.client.lpop this.redisTableKey(key), callback

  retrieve: (key, callback) ->
    idx = if this.inFirst then 0 else -1
    this.client.lindex this.redisTableKey(key), idx, (err, res) ->
      if err then callback err, null; return
      result = if res? then JSON.parse res else null
      callback err, result

  length: (key, callback) ->
    this.client.llen this.redisTableKey(key), callback

  keyDel: (key, callback) ->
    this.client.del this.redisTableKey(key), callback

  keys: (callback) ->
    pattern = this.redisTableKey null, true
    funcScan = (client, cursor, store, callback0) ->
      client.scan cursor, "MATCH", pattern, (err, res) ->
        if err then callback0 err, res; return
        for key in res[1]
          store.push key
        if res[0] isnt "0"
          funcScan client, res[0], store, callback
        else
          callback0 err, store
    funcScan this.client, 0, [], callback

  flush: (callback) ->
    funcDelete = (client, keys, callback0) ->
      target = keys.pop()
      client.del target, (err, res) ->
        if err then callback0? err, null; return
        if keys.length > 0
          funcDelete client, keys, callback0
        else
          callback0? err, true
    cltmp = this.client
    this.keys (err, res) ->
      if err then callback err, null; return
      funcDelete cltmp, res, callback

  save: (callback) ->
    this.client.save callback

  quit: (callback) ->
    this.client.quit callback


module.exports = RedisKeyTable
