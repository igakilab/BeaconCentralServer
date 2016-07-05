BeaconManager = require './beacon-manager'
BeaconCentralServer = require './beacon-central-server'
Bleacon = require 'bleacon'

colorString = (str, ccode) ->
  return "\u001b[#{ccode}m#{str}\u001b[0m"

coloredProxString = (bcon) ->
  return switch bcon.proximity
    when 'immediate'
      colorString bcon.proximity, 31
    when 'near'
      colorString bcon.proximity, 33
    else
      colorString bcon.proximity, 32

beaconLog = (bcon) ->
  uuid = colorString "#{bcon.uuid}(#{bcon.major}-#{bcon.minor})", 36
  prox = coloredProxString bcon
  console.log "uuid:#{uuid}, proximity:#{prox}"
  console.log "\trssi:#{bcon.rssi}(#{bcon.measuredPower}), accuracy:#{bcon.accuracy.toFixed(2)}"

### main ###
manager = new BeaconManager()
Bleacon.on 'discover', (bcon) ->
  manager.applyBeacon bcon, true
  beaconLog(bcon)

server = new BeaconCentralServer manager, "test-server-1"
server.listen 1337
console.log "init: server listening"

Bleacon.startScanning()
console.log "init: start scanning"
