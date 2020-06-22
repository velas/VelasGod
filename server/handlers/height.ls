module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.message.index-of('Imported #') is -1
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \height
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \height , model
    return cb err if err?
    cb null