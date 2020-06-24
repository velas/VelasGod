module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \VERSION
    console.log \version, ws.id, message.message
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \version
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \version , model
    return cb err if err?
    cb null