#import    0/50 peers      5 MiB chain  833 KiB db  0 bytes queue   66 KiB sync  RPC: 27 conn,    0 req/s,   39 µs

require! {
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find }
    \moment
}
#net_Peers

extract-block = (message, cb)->
    return cb null, message.message.match('import    ([0-9]?)')?1 if message.message.index-of('import    ') > -1
    cb "pass"

module.exports = (db, ws, message)->
    cb = ->
    err, block <- extract-block message
    return cb null if err?
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \peer_log
    model = if err? then {} else data
    model[name] = +block
    err <- db.put \peer_log , model
    return cb err if err?
    err <- db.put \peer_log/last-update , moment.utc!
    return cb err if err?
    cb null

ALLOW_DIFFERENCE = 5

module.exports.check = (db, cb)->
    err, data <- db.get \peer_log
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
    return cb "The difference between <b>#{max-item.0}</b> and <b>#{min-item.0}</b> nodes is (#{max} - #{min}) <b>#{max - min}</b> peers" if max > min + ALLOW_DIFFERENCE
    cb null
    
