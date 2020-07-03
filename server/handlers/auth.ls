require! {
    \web3-eth-accounts : Web3EthAccounts
}

method = \AUTH

account = new Web3EthAccounts('ws://localhost:8546')

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt method
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    m = JSON.parse(message.message)
    address = account.recover ws.id, m, ''
    model[name] = address
    err <- db.put method , model
    return cb err if err?
    cb null