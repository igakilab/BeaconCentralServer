Tabledb = require '../redis-db-tools/redis-key-table'
BeaconHistorydb = require './beacon-history-db'
BeaconCachedb = require './beacon-cache-db'

generateBeaconKey = (bcon) ->
  major = bcon.major - 0
  minor = bcon.minor - 0
  digest = Tabledb.hashing "#{bcon.uuid}-#{major}-#{minor}"
  return digest.substr 0, 8

class BeaconManager
  constructor: () ->
    this.historydb = new BeaconHistorydb "beacon", "histories"
    this.historydb.bconKey = generateBeaconKey
    this.cachedb = new BeaconCachedb "beacon", "cache"
    this.cachedb.bconKey = generateBeaconKey

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
        eres.value.key = eres.key
        reply.push eres.value
      callback err, reply

  getBeaconById: (hashedKey, callback) ->
    this.cachedb.getBeaconByHashedKey hashedKey, callback

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
