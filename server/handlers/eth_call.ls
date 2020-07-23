require! {
    \../smarts/get-json.ls
    \../smarts/velas-web3.ls
    \web3/lib/web3/function.js : fun
}

web3 = velas-web3!

method = \eth_call


get-invoked = (message)->
    module.exports.invoked[message.role]

parse-message = (message)->
    m = JSON.parse message.message
    #console.log module.exports.invoked, message.role
    i = get-invoked(message)
    return m if not i?
    json = get-json i.contract, i.method, i.params
    return m if not json
    f = new fun web3.eth, json, ''
    f.unpackOutput m
    
    
module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.role.index-of('Monitor') is -1 or message.type isnt \eth_call
    i = get-invoked(message)
    _method = i?handler ? method
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    _name = i?name ? name
    err, data <- db.get _method
    model = if err? then {} else data
    model[_name] = parse-message(message)
    err <- db.put _method , model
    return cb err if err?
    cb null

module.exports.invoked = {}

#module.exports.poll = get-call "Staking", "stakingEpoch"