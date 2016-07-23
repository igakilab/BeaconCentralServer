BeaconEmulator = require './beacon-emulator'
BeaconManager = require './beacon-manager/beacon-manager'
BeaconCentralServer = require './beacon-central-server'

model1 = {uuid: "54864afd0282435c967b50e534b89695", major: 1, minor: 3, measuredPower: -53}
model2 = {uuid: "54864afd0282435c967b50e534b89695", major: 1, minor: 4, measuredPower: -53}
model3 = {uuid: "81554b2ffe66404c99bc70cedcb54523", major: 0, minor: 120, measuredPower: -53}
model4 = {uuid: "95f428b14a3a4e39b08621bff38deb6d", major: 0, minor: 960, measuredPower: -53}

manager = new BeaconManager()
manager.cachedb.db.flush()
manager.historydb.db.flush()

beacon1 = new BeaconEmulator model1
beacon1.setRssiRange -40, -70
beacon1.onDiscover (bcon) ->
  console.log bcon
  manager.applyBeacon bcon, true

server = new BeaconCentralServer manager, "test-server-1"
server.listen 1337


beacon1.start 500
