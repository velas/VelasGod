require! {
    \prelude-ls : { obj-to-pairs, map }
    \ping
    \isopen
}

#var ping = require('ping');

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

check-availability = ([peer, ...peers], cb)->
    return cb null if not peer?
    [name, address] = peer
    [ip, port] = address.split(":")
    is-alive <- ping.sys.probe ip
    ping-err = 
        | is-alive => null
        | _ => "Ping of #{ip}, so #{name} is could be dead"
    resp <- isopen ip, port
    port-err =
        | resp[port].is-open => null
        | _ => "Port #{port} is closed, so #{name} is dead"
    node-err =
        | ping-err? and not port-err? => null
        | ping-err? and port-err? => "#{name} ping err, #{ip}:#{port} is closed"
        | _ => null
    err <- check-availability peers
    target-err = 
        | node-err? and err? => "#{node-err}\n#{err}"
        | err? => err
        | node-err? => node-err
        | _ => null
    target-err-descriptive =
        | target-err? => "`Ping and port check is performed by monitoring server`\n#{target-err}"
        | _ => null
    cb target-err-descriptive
    

module.exports.check = (db, cb)->
    err, peers <- db.get method
    return cb null if err?
    formatted = 
        peers 
            |> obj-to-pairs
            |> map -> [it.0, parse-ip(it.1)]
        
    err <- check-availability formatted
    return cb err if err?
    cb null