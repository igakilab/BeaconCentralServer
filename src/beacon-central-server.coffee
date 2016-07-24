Express = require 'express'

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

  getAllBeacon: (callback) ->
    reply = {centralId: this.id}
    this.manager.getBeaconList (err, res) ->
      if err then reply.err = err
      reply.beacons = res
      callback reply

  getBeaconHistory: (id, callback) ->
    reply = {centralId: this.id, beaconId: id}
    this.manager.getHistoryById id, (err, res) ->
      if err then reply.err = err
      reply.histories = res
      callback reply

  getBeaconChangesLog: (id, callback) ->
    reply = {centralId: this.id, beaconId: id}
    this.manager.getChangesLogById id, (err, res) ->
      if err then reply.err = err
      reply.changes = res
      callback reply

  buildServer: () ->
    app = Express()
    router = Express.Router()
    thisp = this
    #beacon list
    router.get "/", (req, res) ->
      thisp.getAllBeacon (reply) ->
        res.set 'Access-Control-Allow-Origin', "*"
        res.json reply
    #BeaconHistory
    router.get "/history/:beacon_id", (req, res) ->
      thisp.getBeaconHistory req.params.beacon_id, (reply) ->
        res.set 'Access-Control-Allow-Origin', "*"
        res.json reply
    #BeaconChangesLog
    router.get "/changes/:beacon_id", (req, res) ->
      thisp.getBeaconChangesLog req.params.beacon_id, (reply) ->
        res.set 'Access-Control-Allow-Origin', "*"
        res.json reply
    #configure app
    app.use "/beacon", router
    return app

  listen: (port, host) ->
    app = this.buildServer()
    app.listen port, host

module.exports = BeaconCentralServer
