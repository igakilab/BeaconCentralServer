BeaconManager = require './beacon-manager'
BeaconCentralServer = require './beacon-central-server'
Bleacon = require 'bleacon'

colorString = (str, ccode) ->
  return "\u001b[#{ccode}m#{str}\u001b[0m"

beaconLog = (bcon) ->
  uuid = colorString "#{bcon.uuid}(#{bcon.major}-#{bcon.minor})", 36
  prox = bcon.proximity
  if prox is "immediate"
    prox = colorString prox, 31
  else if prox is "near"
    prox = colorString prox, 33
  else
    prox = colorString prox, 32
  console.log "uuid:#{uuid}, proximity:#{prox}"

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
