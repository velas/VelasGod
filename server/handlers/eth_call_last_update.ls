require! {
    \moment
}

method = \eth_call_last_update



module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.role.index-of('Monitor') is -1 or message.type isnt \eth_call
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    model[name] = moment.utc!.format!
    err <- db.put method , model
    cb null