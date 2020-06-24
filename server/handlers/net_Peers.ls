module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \net_Peers
    console.log \net_Peers, message.message
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \net_Peers
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \net_Peers , model
    return cb err if err?
    cb null