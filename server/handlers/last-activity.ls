require! {
    \moment
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find }
}

get-moment = (message)->
    #console.log message.time
    moment.utc("#{message.date} #{message.time}", "YYYY-MM-DD hh:mm:ss")

module.exports = (db, ws, message)->
    cb = ->
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \lastActivity
    model = if err? then {} else data
    model[name] = get-moment(message).format()
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
    #console.log current, min, max
    from-now = moment.unix(min).from-now!
    problem =
        | min-diff > 10 and from-now isnt '12 hours ago' => "Last activity of `#{min-item}` was `#{from-now}` from now"
        | _ => 
    #console.log problem if problem?
    return cb problem if problem?
    cb null