require! {
    \../utils/json-parse.ls
} 


module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \parity_netPeers
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \peers
    model = if err? then {} else data
    peers = JSON.parse(message.message)
    model[name] = "#{peers.connected} / (#{peers.max})"
    err <- db.put \peers , model
    return cb err if err?
    
    cb null