require! {
    \../utils/make-call.ls
}

module.exports = (db, ws, message)->
    return null
    


module.exports.poll = ({ db, connections }, cb)->
    return cb null
    contract = \Staking
    method = \isPoolActive
    params = ["0x..."]
    handler = \isactive
    err, request <- make-call { contract, method, params, name, handler }
    return cb err if err?
    connections.0.send request