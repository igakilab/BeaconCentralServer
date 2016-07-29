Crypto = require 'crypto'
Redis = require 'redis'

SEPARATOR = ":"

FUNC_HASHING = (key) ->
  alg = Crypto.createHash "md5"
  alg.update key
  return alg.digest "hex"


class RedisKeyHash
  @hashing: FUNC_HASHING

  @createClient: (dbname, colname, port, host, opt) ->
    client = Redis.createClient port, host, opt
    return new RedisKeyHash client, dbname, colname

  @cloneClient: (dbc, dbname, colname) ->
    client = dbc.client ? dbc
    return new RedisKeyHash client, dbname, colname

  constructor: (client, dbname, colname) ->
    this.client = client
    this.dbname = dbname
    this.colname = colname
    this.autoHash = true

  redisKey: () ->
    return "#{this.dbname}#{SEPARATOR}#{this.colname}"

  fieldHash: (key) ->
    return if this.autoHash then RedisKeyHash.hashing key else key

  get: (key, callback) ->
    this.client.hget this.redisKey(), this.fieldHash(key), (err, res) ->
      if err then callback err, null; return
      callback err, JSON.parse res

  set: (key, value, callback) ->
    record = JSON.stringify value
    this.client.hset this.redisKey(), this.fieldHash(key), record, callback

  setnx: (key, value, callback) ->
    record = JSON.stringify value
    this.client.hsetnx this.redisKey(), this.fieldHash(key), record, callback

  del: (key, callback) ->
    this.client.hdel this.redisKey(), this.fieldHash(key), callback

  exists: (key, callback) ->
    this.client.hexists this.redisKey(), this.fieldHash(key), callback

  keys: (callback) ->
    this.client.hkeys this.redisKey(), callback

  getAll: (callback) ->
    this.client.hgetall this.redisKey(), (err, res) ->
      if err then callback err, null; return
      result = []
      for k,v of res
        result.push {key:k, value: JSON.parse v}
      callback err, result

  flush: (callback) ->
    this.client.del this.redisKey(), callback

  save: (callback) ->
    this.client.save callback

  quit: (callback) ->
    this.client.quit callback


module.exports = RedisKeyHash
