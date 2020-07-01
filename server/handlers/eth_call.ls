require! {
    \../smarts/get-types.ls
    \../smarts/velas-web3.ls
    \web3/lib/solidity/coder.js
}

web3 = velas-web3!

method = \eth_call

#res = coder.decodeParams ['uint256'], '0x0000000000000000000000000000000000000000000000000000000000000209'
#console.log \test , res.to-string!

console.log '!!!', coder.decodeParams([ 'uint256' ], "0x0000000000000000000000000000000000000000000000000000000000000209").to-string!
console.log '!!!', coder.decodeParams([ 'uint256' ], "0x0000000000000000000000000000000000000000000000000000000000000209").to-string!
console.log '!!!', coder.decodeParams([ 'uint256' ], "0x0000000000000000000000000000000000000000000000000000000000000209").to-string!



parse-message = (message)->
    m = JSON.parse message
    i = module.exports.invoked
    return m if not i?
    types = get-types i.contract, i.method, i.params
    return m if not types
    console.log types, message
    try
        return coder.decodeParams(types, message).to-string!
    catch err
        console.log err, types, message
        return m
    
module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \eth_call
    console.log \eth_call, message.message
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    model[name] = parse-message(message.message)
    err <- db.put method , model
    return cb err if err?
    cb null


#module.exports.poll = get-call "Staking", "stakingEpoch"