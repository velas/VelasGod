module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \PLATFORM
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \platform
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \platform , model
    return cb err if err?
    cb null