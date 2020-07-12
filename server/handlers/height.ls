require! {
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find }
    \moment
}
#net_Peers

extract-block = (message, cb)->
    return cb null, message.message.match('(#)([0-9]+)')?2 if message.message.index-of('Imported #') > -1
    return cb null, message.message.match('(#)([0-9]+)')?2 if message.type is \DEBUG and message.message.index-of('we are step proposer for step=') > -1
    cb "pass"

module.exports = (db, ws, message)->
    cb = ->
    err, block <- extract-block message
    return cb null if err?
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \height
    model = if err? then {} else data
    model[name] = +block
    err <- db.put \height , model
    return cb err if err?
    err <- db.put \height/last-update , moment.utc!
    return cb err if err?
    cb null

ALLOW_DIFFERENCE = 2

module.exports.check = (db, cb)->
    err, data <- db.get \height
    return cb null if err?
    items =
        | err? => []
        | _ => obj-to-pairs data 
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
    #console.log \check-height, max-item, min-item
    return cb "The difference between <b>#{max-item.0}</b> and <b>#{min-item.0}</b> height is (#{max} - #{min}) <b>#{max - min}</b> blocks" if max > min + ALLOW_DIFFERENCE
    cb null
    