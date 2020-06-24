module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \parity_nodeKind
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \parity_nodeKind
    model = if err? then {} else data
    kind = JSON.parse message.message
    model[name] = "#{kind.availability} / #{kind.capability}"
    err <- db.put \parity_nodeKind , model
    return cb err if err?
    
    cb null