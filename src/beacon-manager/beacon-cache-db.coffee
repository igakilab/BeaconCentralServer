Hashdb = require '../redis-db-tools/redis-key-hash'

class BeaconCacheDatabase
  constructor: (dbname, colname) ->
    this.db = Hashdb.createClient dbname, colname
    this.db.autoHash = false

  bconKey: (bcon) ->
    major = bcon.major - 0
    minor = bcon.minor - 0
    return Hashdb.hashing "#{bcon.uuid}-#{major}-#{minor}"

  applyBeacon: (bcon, callback) ->
    this.db.set this.bconKey(bcon), bcon, callback

  getBeaconByHashedKey: (hashedKey, callback) ->
    this.db.getAll (err, res) ->
      if err then callback err, null; return
      result = null
      for pair in res
        if pair.key is hashedKey
          result = pair.value
          break
      callback err, result

  getAllBeacon: (callback) ->
    this.db.getAll callback

  quit: (callback) ->
    this.db.quit callback


module.exports = BeaconCacheDatabase
