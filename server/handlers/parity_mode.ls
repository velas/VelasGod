module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \parity_mode
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \parity_mode
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \parity_mode , model
    return cb err if err?
    
    cb null