require! {
    \../utils/json-parse.ls
} 

module.exports = (db, ws, message)->
    cb = (err)->
        console.log err if err?
    return cb null if message.type isnt \CONFIG
    err, config <- json-parse message.message
    return cb err if err?
    name = config.parity?identity
    return cb "identity is required" if not name?
    err, data <- db.get \mining_address
    model = 
        | err =>  {}
        | _ => data
    model[name] = config.mining?engine_signer ? 'n/a'
    err <- db.put \mining_address , model
    return cb err if err?
    err <- db.put "ws/#{ws.id}", name
    return cb err if err?
    cb null