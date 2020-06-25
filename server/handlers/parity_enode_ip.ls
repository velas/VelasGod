module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \parity_enode
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \parity_enode_ip
    model = if err? then {} else data
    model[name] = JSON.parse(message.message).split('@')?1
    err <- db.put \parity_enode_ip , model
    return cb err if err?
    cb null