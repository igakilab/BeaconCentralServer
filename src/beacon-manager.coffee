class BeaconManager
  constructor: () ->
    this.beacons = []

  getBeaconIndex: (bcon) ->
    for i in [0...this.beacons.length]
      if this.beaconEquals bcon, this.beacons[i]
        return i
    return -1


#  getBeaconIndexByUuid: (id) ->
#    for i in [0...this.beacons.length]
#      if this.beacons[i].uuid and this.beacons[i].uuid is id
#        return i
#    return -1
#
#  getBeaconByUuid: (id) ->
#    idx = this.getBeaconIndexByUuid id
#    if idx >= 0
#      return this.beacons[idx]
#    else
#      return null


  applyBeacon: (bcon, tmark) ->
    if tmark then bcon.timeStamp = new Date()
    idx = this.getBeaconIndex bcon
    if idx >= 0
      this.beacons[idx] = bcon
    else
      this.beacons.push bcon

  getBeaconList: (bcon) ->
    return this.beacons.concat()

  beaconEquals: (b1, b2) ->
    if b1 and b2
      if b1.uuid isnt b2.uuid
        return false
      if b1.major isnt b2.major
        return false
      if b1.minor isnt b2.minor
        return false
    return true


# export module
module.exports = BeaconManager
