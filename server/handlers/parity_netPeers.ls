module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \parity_netPeers
    console.log \parity_netPeers, message.message
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \parity_netPeers
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \parity_netPeers , model
    return cb err if err?
    cb null