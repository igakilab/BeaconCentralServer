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
        dif = newBcon.timestamp - retrieve.timestamp?
        return dif > this.interval
      else
        return true
    else
      return true

  applyBeacon: (bcon, callback) ->
    this.db.retrieve this.bconKey(bcon), (err, res) ->
      if err then callback err, null; return
      if this.canBeaconApply bcon, res
        this.addBeaconToDB bcon, callback
      else
        callback err, false

  addBeaconToDB: (bcon, callback) ->
    this.db.push this.bconKey(bcon), (err, res) ->
      if err then callback err, null; return
      if res > this.listLength
        this.db.shift this.bconKey(bcon), callback
      else
        callback err, res

  getBeaconHistory: (uuid, major, minor, callback) ->
    bcon = {uuid: uuid, major: major, minor: minor}
    this.db.get this.bconKey(bcon), callback


module.exports = BeaconHisotryDatabase
