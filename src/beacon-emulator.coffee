class BeaconEmulator
  @defaultModel:
    uuid: "641e1c84032f45e88aa219857fdd640b"
    major: 0
    minor: 0

  @defaultInterval: 500

  @defaultRssi: [-70..-50]

  @random: (array) ->
    return array[Math.floor(Math.random() * array.length)]

  constructor: (model, onDiscover) ->
    this.model = model ? BeaconEmulator.defaultModel
    this.onDiscover = onDiscover
    this.rssis = BeaconEmulator.defaultRssi
    this.pid = null

  setModel: (model) ->
    this.model = model

  setRssiRange: (min, max) ->
    this.rssis = [min..max]

  exec: () ->
    bcon = {}
    for k,v of this.model
      bcon[k] = v
    bcon.rssi = random this.rssis
    this.onDiscover? bcon

  start: (interval) ->
    if this.pid is null
      this.pid = setInterval this.exec, interval

  stop: () ->
    if this.pid isnt null
      clearInterval this.pid
      this.pid = null

  isRun: () ->
    return this.pid isnt null
