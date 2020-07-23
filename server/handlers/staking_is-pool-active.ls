#require! {
#    \../utils/make-call.ls
#}
#
#module.exports = (db, ws, message)->
#    return null
#
#
#module.exports.poll = ({ db, connections }, cb)->
#    return cb null
#    contract = \Staking
#    method = \isPoolActive
#    params = ["0x..."]
#    handler = \isactive
#    err, request <- make-call { contract, method, params, name, handler }
#    return cb err if err?
#    connections.0.send request

require! {
    \../utils/make-call.ls
    \prelude-ls : { obj-to-pairs }
}

module.exports = (db, ws, message)->
    return null


ask-is-active = (item, connections, cb)->
    [name, mining_address] = item
    return cb null if mining_address is \n/a
    contract = \Staking
    method = \isPoolActive
    params = [mining_address]
    handler = \is_pool_active
    err, request <- make-call { contract, method, params, name, handler }
    return cb err if err?
    connections.0.send request
    cb null

ask-is-actives = ([item, ...items], connections, cb)->
    return cb null if not item?
    err <- ask-is-active item, connections
    <- set-immediate
    ask-is-actives items, connections, cb

#ValidatorSet.stakingByMiningAddress
module.exports.poll = ({ db, connections }, cb)->
    err, staking_address <- db.get \staking_address
    return cb err if err?
    items =
        staking_address 
            |> obj-to-pairs
    ask-is-actives items, connections, cb
    