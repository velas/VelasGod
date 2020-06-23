require! {
    \moment
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find }
}

get-moment = (message)->
    moment.utc("#{message.date} #{message.time}", "YYYY-MM-DD hh:mm:ss")

module.exports = (db, ws, message)->
    cb = ->
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \lastActivity
    model = if err? then {} else data
    model[name] = get-moment(message).format!
    err <- db.put \lastActivity , model
    return cb err if err?
    cb null

module.exports.check = (db, cb)->
    err, data <- db.get \lastActivity
    return cb null if err?
    time = -> moment.utc(it.1).unix!
    items =
        data 
            |> obj-to-pairs
    nix-times =
        items
            |> map time
    max = maximum nix-times
    min = minimum nix-times
    current = moment.utc!.unix!
    max-item =
        items
            |> find -> time(it) is max
    min-item =
        items
            |> find -> time(it) is min
    min-diff = current - min
    max-diff = current - max
    return cb "Last activity of #{min-item} was #{min-diff} seconds from now. (Also it compares dates between servers so it could be a problem as well)" if min-diff > 10
    #return cb "The difference between height is more than #{ALLOW_DIFFERENCE} blocks #{max} (#{max-item.0}) > #{min} (#{min-item.0})" if max > min + ALLOW_DIFFERENCE
    cb null