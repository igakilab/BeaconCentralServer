RedisTable = require './redis-key-table'
RedisHash = require './redis-key-hash'

class BeaconManager
  constructor: () ->
    this.tdb = RedisTable.createClient "beacon", "histories"
    this.hdb = RedisHash.cloneClient this.tdb, "beacon", "cache"

  beaconStringKey: (uuid, major, minor) ->
    major = major - 0
    minor = minor - 0
    return "#{uuid}-#{major}-#{minor}"

  errorHandler: (err, res) ->
    console.log err

  applyBeacon: (bcon, tmark) ->
    if tmark then bcon.timestamp = Date.now()
    skey = this.beaconStringKey bcon.uuid, bcon.major, bcon.minor
    tdb.push skey, bcon, this.errorHandler
    hdb.push skey, bcon, this.errorHandler

  getBeaconList: (bcon, callback) ->
    hdb.getAll (err, res) ->
      if err then callback err, res; return
      result = []
      for eres in res
        result.push eres.value
      callback err, result

  getBeaconHistory: (uuid, major, minor, callback) ->
    skey = beaconStringKey uuid, major, minor
    tdb.get skey, (err, res) ->
      if err then callback err, null; return
      callback err, res.toArray()


# export module
module.exports = BeaconManager
