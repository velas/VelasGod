module.exports = (db, ws, message)->
    cb = console.log
    name = ws.id
    err, data <- db.get \last-activity
    return cb err if err?
    model = data ? {}
    model[name] = message.date + " " + message.time
    err <- db.put "last-activity", model
    return cb err if err?
    cb null