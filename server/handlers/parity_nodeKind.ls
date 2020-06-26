method = \parity_nodeKind

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt method
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    kind = JSON.parse message.message
    model[name] = "#{kind.availability} / #{kind.capability}"
    err <- db.put method , model
    return cb err if err?
    cb null

module.exports.poll = JSON.stringify { method }