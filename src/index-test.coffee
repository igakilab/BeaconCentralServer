beacon1 = {
  uuid: "54864afd0282435c967b50e534b89695"
  major: 1
  minor: 3
  proximity: 'near'
}
beacon2 = {
  uuid: "54864afd0282435c967b50e534b89695"
  major: 1
  minor: 4
  proximity: 'immediate'
}
beacon3 = {
  uuid: "81554b2ffe66404c99bc70cedcb54523"
  major: 0
  minor: 960
  proximity: 'immediate'
}
beacon4 = {
  uuid: "95f428b14a3a4e39b08621bff38deb6d"
  major: 0
  minor: 960
  measuredPower:-53
  rssi:-44
  accuracy:0.5310240747641771
  proximity:"near"
}

loops = (manager) ->
  proximities = ['immediate', 'near', 'far']
  beacon2.proximity = proximities[Math.floor(Math.random() * proximities.length)]
  manager.applyBeacon beacon2, true
  setTimeout () ->
    loops(manager)
  ,2500


BeaconManager = require './beacon-manager'
manager = new BeaconManager()

manager.applyBeacon beacon1, true
manager.applyBeacon beacon3
manager.applyBeacon beacon4

loops(manager);

BeaconCentralServer = require './beacon-central-server'
server = new BeaconCentralServer manager, "test-server-1"
console.log server.getReply()
server.listen 1337
