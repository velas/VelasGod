module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \FREEMEM
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \freemem
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \freemem , model
    return cb err if err?
    cb null