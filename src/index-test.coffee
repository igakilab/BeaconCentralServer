BeaconManager = require './beacon-manager'
BeaconCentralServer = require './beacon-central-server'

rndBeacons = [
  {uuid: "54864afd0282435c967b50e534b89695", major: 1, minor: 3, measuredPower: -53}
  {uuid: "54864afd0282435c967b50e534b89695", major: 1, minor: 4, measuredPower: -53}
  {uuid: "81554b2ffe66404c99bc70cedcb54523", major: 0, minor: 120, measuredPower: -53}
  {uuid: "95f428b14a3a4e39b08621bff38deb6d", major: 0, minor: 960, measuredPower: -53}
]
rndRssis = [-40..-70]

random = (array) ->
  return array[Math.floor(Math.random() * array.length)]

generateBeacon = () ->
  inf = random rndBeacons
  bcon =
    uuid: inf.uuid
    major: inf.major
    minor: inf.minor
    rssi = random rndRssis
  bcon.accuracy = Math.pow 12.0, (1.5*((bcon.rssi/bcon.measuredPower)-1))
  if bcon.accuracy < 0
    bcon.proximity = "unknown"
  else if bcon.accuracy < 0.5
    bcon.proximity = "immediate"
  else if bcon.accuracy < 4.0
    bcon.proximity = "near"
  else
    bcon.proximity = "far"
  return bcon

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
beacon3 =,{
  uuid: "81554b2ffe66404c99bc70cedcb54523",
  major: 0
  minor: 120
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
