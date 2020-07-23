require! {
    \prelude-ls : { obj-to-pairs, map, filter, join }
    \ping
    \isopen
}


method = \parity_enode

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt method
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    model[name] = JSON.parse(message.message)
    err <- db.put method , model
    return cb err if err?
    cb null
    
module.exports.poll = JSON.stringify { method }

parse-ip = (enode)->
    [enode_id, address] = enode.split('@')
    address

check-peer = (peer, cb)->
    [name, address] = peer
    [ip, port] = address.split(":")
    resp <- isopen ip, port
    port-err =
        | resp[port].is-open is yes => null
        | _ => "Port #{port} is closed, so #{name} is dead"
    cb port-err

check-availability = ([peer, ...peers], cb)->
    return cb null if not peer?
    err-peer <- check-peer peer
    err-rest <- check-availability peers
    errs = 
        [err-peer, err-rest] |> filter (?)
    err = 
        | errs.length > 0 => join \\n , errs
        | _ => null
    cb err

module.exports.check = (db, cb)->
    return cb null
    err, peers <- db.get method
    return cb null if err?
    formatted =
        peers
            |> obj-to-pairs
            |> map -> [it.0, parse-ip(it.1)]
    err <- check-availability formatted
    err2 = 
        | err? => "`Monitoring server check availability of other nodes`\n#{err}"
        | _ => null
    return cb err2 if err2?
    cb null