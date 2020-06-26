method = \parity_gasPriceHistogram

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt method
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    model[name] = JSON.parse(message.message)
    err <- db.put method , model
    return cb err if err?
    cb null
    
module.exports.poll = JSON.stringify { method, { params: { limit: 100 } } }