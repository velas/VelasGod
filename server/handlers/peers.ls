require! {
    \../utils/json-parse.ls
    \moment
    \prelude-ls : { obj-to-pairs, map, filter, join }
} 


module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \parity_netPeers
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \peers
    model = if err? then {} else data
    peers = JSON.parse(message.message)
    model[name] = "#{peers.connected} / (#{peers.max})"  #+ " <i>#{moment.utc!.from-now!}</i>"
    err <- db.put \peers , model
    return cb err if err?
    err <- db.put \peer/last-update , moment.utc!
    return cb err if err?
    cb null
    
parse-connected = (value)->
    i = value.split("/").0.trim!
    +i

module.exports.check = (db, cb)->
    err, data <- db.get \peers
    return cb null if err?
    model = if err? then {} else data
    err =
        model 
            |> obj-to-pairs
            |> map -> [it.0, parse-connected(it.1)]
            |> filter -> it.1 < 5
            |> map -> "#{it.0} has #{it.1} peers"
            |> join ","
            |> -> if it.length >0 then it
    console.log model if err?
    return cb err if err?
    cb null
    