class BeaconCentralServer
  constructor: (manager, inid) ->
    this.manager = null
    this.id = inid ? "5b7879aa-4c7a-4f29-995b-1ea16990e811"
    this.setManager manager

  setManager: (mngr) ->
    if mngr and typeof mngr.getBeaconList is "function"
      this.manager = mngr

  setServerId: (id) ->
    this.id = id ? this.id

  getReply: () ->
    obj =
      centralId: this.id
      beacons: this.manager.getBeaconList()
    return obj

  listen: (port, host) ->
    bcs = this
    http = require 'http'
    server = http.createServer (req, res) ->
      res.writeHead 200, {
        'Content-Type': "application/json"
        'Access-Control-Allow-Origin': "*"}
      res.write JSON.stringify(bcs.getReply())
      res.end()
    server.listen port, host


module.exports = BeaconCentralServer
