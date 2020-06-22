require! {
    \moment
}


module.exports = (db, ws, message)->
    cb = ->
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \lastActivity
    model = if err? then {} else data
    model[name] = moment.utc("#{message.date} #{message.time}", "YYYY-MM-DD hh:mm:ss").from-now!
    #model[name] = message.date + " " + message.time
    err <- db.put \lastActivity , model
    return cb err if err?
    cb null