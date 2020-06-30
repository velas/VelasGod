require! {
    \prelude-ls : { obj-to-pairs, map, join }
}

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.message.index-of('reorg') is -1
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \reorg
    model = if err? then {} else data
    model[name] = message.message
    err <- db.put \reorg , model
    return cb err if err?
    cb null
    
module.exports.check = (db, cb)->
    err, data <- db.get \reorg
    return cb null if err?
    items =
        data 
            |> obj-to-pairs
            |> map (.0)
            |> join ","
    return cb null if items.length is 0
    cb "REORG IS ON #{items}"
    #cleanup
    db.put \reorg , {}, ->
    