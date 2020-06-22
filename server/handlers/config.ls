require! {
    \../utils/json-parse.ls
} 

module.exports = (db, ws, message)->
    cb = (err)->
        console.log err if err?
    return cb null if message.type isnt \CONFIG
    console.log \CONFIG
    err, config <- json-parse message.message
    return cb err if err?
    name = config.parity?identity
    return cb "identity is required" if not name?
    err, data <- db.get \config
    model = 
        | err =>  {}
        | _ => data
    model[name] = config
    err <- db.put \config , model
    return cb err if err?
    err <- db.put "ws/#{ws.id}", name
    return cb err if err?
    cb null