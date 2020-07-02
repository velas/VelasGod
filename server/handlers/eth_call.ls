require! {
    \../smarts/get-json.ls
    \../smarts/velas-web3.ls
    \web3/lib/web3/function.js : fun
}

web3 = velas-web3!

method = \eth_call




parse-message = (message)->
    m = JSON.parse message
    i = module.exports.invoked
    return m if not i?
    json = get-json i.contract, i.method, i.params
    return m if not json
    f = new fun web3.eth, json, ''
    f.unpackOutput m
    
    
module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \eth_call
    console.log \eth_call, message
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    model[name] = parse-message(message.message)
    err <- db.put method , model
    return cb err if err?
    cb null


#module.exports.poll = get-call "Staking", "stakingEpoch"