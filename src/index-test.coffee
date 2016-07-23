BeaconEmulator = require './beacon-emulator'
BeaconManager = require './beacon-manager/beacon-manager'

model1 = {uuid: "54864afd0282435c967b50e534b89695", major: 1, minor: 3, measuredPower: -53}
model2 = {uuid: "54864afd0282435c967b50e534b89695", major: 1, minor: 4, measuredPower: -53}
model3 = {uuid: "81554b2ffe66404c99bc70cedcb54523", major: 0, minor: 120, measuredPower: -53}
model4 = {uuid: "95f428b14a3a4e39b08621bff38deb6d", major: 0, minor: 960, measuredPower: -53}

manager = new BeaconManager()

beacon1 = new BeaconEmulator model1
beacon1.setRssiRange -40, -70
beacon1.onDiscover (bcon) ->
  console.log bcon
  manager.applyBeacon bcon, true

manager.historydb.db.flush()

beacon1.start 500

terminate = () ->
  beacon1.stop()
  manager.getBeaconList (err, res) ->
    console.log res
    for eres in res
      manager.getHistoryById eres.hid, (err, res) ->
        console.log eres.hid
        console.log res
  setTimeout () ->
    manager.quit()
  , 3000

setTimeout () ->
  terminate()
, 5000
