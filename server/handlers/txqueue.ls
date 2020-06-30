require! {
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find, each }
}

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \TRACE
    return cb null if message.message.index-of('txqueue') is -1
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    res = message.message.match(/txqueue \s\[(\S+)\] (.+)/)
    return cb null if not res?
    [ _, txid, reason ] = res
    err, data <- db.get \txqueue
    model = if err? then {} else data
    model[txid] = reason
    err <- db.put \txqueue , model
    return cb err if err?
    cb null

remove-transaction = (data, connections, hash)-->
    remove_transaction = 
        method: \parity_removeTransaction
        params: [hash]
    current = JSON.stringify remove_transaction
    connections |> each (-> it.send current)
    delete data[hash]

module.exports.clear-all = (db, connections, cb)->
    return cb "no any peers" if connections.length is 0
    err, data <- db.get \txqueue
    return cb err if err?
    txhashes =
        data 
            |> obj-to-pairs 
            |> map (.0)
    console.log \txhashes , txhashes
    txhashes |> each remove-transaction data, connections
    err <- db.put \txqueue , data
    return cb err if err?
    cb null

