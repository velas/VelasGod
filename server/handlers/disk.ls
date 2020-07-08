require! {
    \prelude-ls : { obj-to-pairs, map, join, filter }
    \moment
}

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \DISK
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \disk
    model = if err? then {} else data
    try
        model[name] = (Math.round(+message.message * 100) / 100) + ' GB'
    catch 
        model[name] = message.message
    err <- db.put \disk , model
    return cb err if err?
    err <- db.put \disk/last-update , moment.utc!
    return cb err if err?
    cb null

check-space = ([name, space])->
    res = space.match('([0-9\.]+) GB')
    #console.log res
    return yes if not res?
    [_, num] = res
    return yes if +num < 2
    no
module.exports.check = (db, cb)->
    err, data <- db.get \disk
    return cb null if err?
    items =
        data 
            |> obj-to-pairs
            |> filter check-space
            |> map (.0)
            |> join ","
    return cb null if items.length is 0
    cb "Available disk is low on #{items}"

module.exports.poll = \diskusage