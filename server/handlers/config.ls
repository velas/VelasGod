module.exports = (db, ws, message)->
    name = ws.id
    cb = console.log
    return cb null
    err, data <- db.get "config"
    return cb err if err?
    model = data ? {}
    console.log message
    model[name] = message
    err <- db.put "config", model
    return cb err if err?
    cb null