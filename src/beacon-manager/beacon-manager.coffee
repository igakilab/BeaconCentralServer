BeaconHistorydb = require './beacon-history-db'
BeaconCachedb = require './beacon-cache-db'

DETECT_TIMEOUT = 10000

class BeaconManager
  constructor: () ->
    this.historydb = new BeaconHistorydb "beacon", "histories"
    this.cachedb = new BeaconCachedb "beacon", "cache"
    this.detectTimeout = DETECT_TIMEOUT

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
    this.cachedb.getBeaconByHashedKey hashedKey, (err, res) ->
      if err then callback err, null; return
      unless res? then callback err, []; return
      mng.historydb.getBeaconHistory res.uuid, res.major, res.minor, callback

  getChangesLog: (hashedKey, callback) ->
    t = this
    this.getHistoryById hashedKey, (err, res) ->
      if err then callback err, null; return
      changes = []
      for i in [0...res.length]
        pre = if changes > 0 then changes[changes.length-1] else null
        if pre? and (res[i].timestamp - pre.timestamp) >= t.detectTimeout
          changes.push {
            timestamp: pre.timestamp + t.detectTimeout
            proximity: "unknown"
          }
          pre = changes[changes.length - 1]
        if !pre? or pre.proximity isnt res[i].proximity
          changes.push {
            timestamp: res[i].timestamp
            proximity: res[i].proximity
          }
      if changes.length > 0
        if (Date.now() - changes[changes.length-1].timestamp) >= t.detectTimeout
           changes.push {
             timestamp: changes[changes.length-1].timestamp + t.detectTimeout
             proximity: "unknown"
           }
      callback err, changes

  quit: () ->
    this.historydb.quit()
    this.cachedb.quit()


# export module
module.exports = BeaconManager
