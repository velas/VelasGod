require! {
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find }
}
#net_Peers
module.exports = (db, ws, message)->
    cb = ->
    #consider also 2020-06-24 14:38:40 UTC http.worker140 DEBUG txqueue  Re-computing pending set for block: 1433734
    return cb null if message.message.index-of('Imported #') is -1
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \height
    model = if err? then {} else data
    model[name] = +message.message.match('(#)([0-9]+)')?2
    err <- db.put \height , model
    return cb err if err?
    cb null

ALLOW_DIFFERENCE = 2

module.exports.check = (db, cb)->
    err, data <- db.get \height
    return cb null if err?
    items =
        data 
            |> obj-to-pairs 
    heights =
       items
            |> map (.1)
    max = maximum heights
    min = minimum heights
    max-item =
        items 
            |> find (.1 is max)
    min-item =
        items
            |> find (.1 is min)
    return cb "The difference between <b>#{max-item.0}</b> and <b>#{min-item.0}</b> height is (#{max} - #{min}) <b>#{max - min}</b> blocks" if max > min + ALLOW_DIFFERENCE
    cb null
    