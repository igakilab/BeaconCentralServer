Tabledb = require '../redis-db-tools/redis-key-table'

DEFAULT_LIST_LENGTH = 1000
DEFAULT_INTERVAL = 1000

class BeaconHistoryDatabase
  constructor: (dbname, colname) ->
    this.db = Tabledb.createClient dbname, colname
    this.listLength = DEFAULT_LIST_LENGTH
    this.interval = DEFAULT_INTERVAL

  bconKey: (bcon) ->
    major = bcon.major - 0
    minor = bcon.minor - 0
    return "#{bcon.uuid}-#{bcon.major}-#{bcon.minor}"

  canBeaconApply: (newBcon, retrieve) ->
    if retrieve?
      if newBcon.timestamp? and retrieve.timestamp?
        dif = newBcon.timestamp - retrieve.timestamp
        return dif > this.interval
      else
        return true
    else
      return true

  applyBeacon: (bcon, callback) ->
    mng = this
    this.db.retrieve this.bconKey(bcon), (err, res) ->
      if err then callback err, null; return
      if mng.canBeaconApply bcon, res
        mng.addBeaconToDB bcon, callback
      else
        callback? err, false

  addBeaconToDB: (bcon, callback) ->
    t = this
    this.db.push this.bconKey(bcon), bcon, (err, res) ->
      if err then callback err, null; return
      if res > t.listLength
        t.db.shift t.bconKey(bcon), callback
      else
        callback? err, res

  getBeaconHistory: (uuid, major, minor, callback) ->
    bcon = {uuid: uuid, major: major, minor: minor}
    this.db.get this.bconKey(bcon), (err, res) ->
      if err then callback err, null; return
      callback err, res.toArray()

  quit: (callback) ->
    this.db.quit callback

module.exports = BeaconHistoryDatabase
