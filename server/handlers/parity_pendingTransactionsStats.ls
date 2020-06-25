name = \parity_pendingTransactionsStats

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt name
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get name
    model = if err? then {} else data
    model[name] = JSON.parse(message.message)
    err <- db.put name , model
    return cb err if err?
    
    cb null
    
module.exports.poll = JSON.stringify { method: name }