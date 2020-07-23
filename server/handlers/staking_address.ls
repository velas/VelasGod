require! {
    \../utils/make-call.ls
    \prelude-ls : { obj-to-pairs }
}

module.exports = (db, ws, message)->
    return null


ask-staking-address = (item, connections, cb)->
    [name, mining_address] = item
    return cb null if mining_address is 'n/a'
    contract = \ValidatorSet
    method = \stakingByMiningAddress
    params = [mining_address]
    handler = \staking_address
    err, request <- make-call { contract, method, params, name, handler }
    return cb err if err?
    connections.0.send request
    cb null

ask-staking-addresses = ([item, ...items], connections, cb)->
    return cb null if not item?
    err <- ask-staking-address item, connections
    
    <- set-immediate
    ask-staking-addresses items, connections, cb

#ValidatorSet.stakingByMiningAddress
module.exports.poll = ({ db, connections }, cb)->
    err, mining_address <- db.get \mining_address
    return cb err if err?
    items =
        mining_address 
            |> obj-to-pairs
    ask-staking-addresses items, connections, cb
    