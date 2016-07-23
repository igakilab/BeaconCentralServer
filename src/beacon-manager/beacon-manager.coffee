BeaconHistorydb = require './beacon-history-db'
BeaconCachedb = require './beacon-cache-db'

class BeaconManager
  constructor: () ->
    this.historydb = new BeaconHistorydb "beacon", "histories"
    this.cachedb = new BaeconCachedb "beacon", "cache"

  errorHandler: (err, res) ->
    console.log err

  applyBeacon: (bcon, tmark) ->
    if tmark then bcon.timestamp = Date.now()
    this.historydb.applyBeacon bcon
    this.cachedb.applyBeacon bcon

  getBeaconList: (callback) ->
    cacheDb.getAll (err, res) ->
      if err then callback err, res; return
      reply = []
      for eres in res
        eres.hid = eres.key
        reply.push eres
      callback err, reply

  getHistoryById: (hashedKey, callback) ->
    this.cachedb.getBeconByHashedKey hashedKey, (err, res) ->
      if err then callback err, null; return
      historydb.getBeaconHistory res.uuid, res.major, callback


# export module
module.exports = BeaconManager
