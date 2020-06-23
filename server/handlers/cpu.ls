module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \CPU
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \cpu
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \cpu , model
    return cb err if err?
    cb null