require! {
    \moment
}

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \CPU
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \cpu
    model = if err? then {} else data
    try 
        model[name] = (Math.round(+message.message * 100) / 100) + "% used"
    catch
        model[name] = message.message
    err <- db.put \cpu , model
    return cb err if err?
    err <- db.put \cpu/last-update , moment.utc!
    return cb err if err?
    cb null
    
module.exports.poll = \cpu_usage