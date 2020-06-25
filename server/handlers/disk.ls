module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \DISK
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \disk
    model = if err? then {} else data
    try
        model[name] = (Math.round(+message.message * 100) / 100) + ' GB'
    catch 
        model[name] = message.message
    err <- db.put \disk , model
    return cb err if err?
    cb null
    
module.exports.poll = \diskusage