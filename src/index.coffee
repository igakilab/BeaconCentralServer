BeaconManager = require './beacon-manager'
BeaconCentralServer = require './beacon-central-server'
Bleacon = require 'bleacon'

manager = new BeaconManager()
Bleacon.on 'discover', (bcon) ->
  manager.applyBeacon bcon, true

server = new BeaconCentralServer manager, "test-server-1"
server.listen 1337

Bleacon.startScanning()
