BeaconHistorydb = require './beacon-history-db'
BeaconCachedb = require './beacon-cache-db'

class BeaconManager
  constructor: () ->
    this.historydb = new BeaconHistorydb "beacon", "histories"
    this.cachedb = new BeaconCachedb "beacon", "cache"

  errorHandler: (err, res) ->
    console.log err

  applyBeacon: (bcon, tmark) ->
    if tmark then bcon.timestamp = Date.now()
    this.historydb.applyBeacon bcon
    this.cachedb.applyBeacon bcon

  getBeaconList: (callback) ->
    this.cachedb.getAllBeacon (err, res) ->
      if err then callback err, res; return
      reply = []
      for eres in res
        eres.value.hid = eres.key
        reply.push eres.value
      callback err, reply

  getHistoryById: (hashedKey, callback) ->
    mng = this
    this.historydb.getBeaconHistoryByKey hashedKey, (err, res) ->
      if err then callback err, null; return
      callback err, res

  quit: () ->
    this.historydb.quit()
    this.cachedb.quit()


# export module
module.exports = BeaconManager
