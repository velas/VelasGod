module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \UPTIME
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \uptime
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \uptime , model
    return cb err if err?
    cb null
    
module.exports.poll = \uptime