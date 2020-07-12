require! {
    \prelude-ls : { obj-to-pairs, map, join, each, keys }
    \moment
}

state =
    counter: 0

module.exports = (db, ws, message)->
    cb = ->
    current_producer = message.message.index-of('we are step proposer for step') isnt -1
    #committee = message.message.index-of('Not preparing block: not a proposer for step') isnt -1
    epoch_change = message.message.index-of('detected epoch change event bloom') isnt -1
    return cb null if not current_producer and not epoch_change
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get \committee
    model = if err? then {} else data
    reset = ->
        model[it] = "..."
    if epoch_change
        model |> keys |> each reset
    if current_producer is yes
        model[name] = model[name] ? 0
        if model[name] > 0 and model[name] < state.counter
            state.counter = 1
        else
            state.counter += 1
        model[name] = state.counter
    #if committee
    #    model[name] = "..."
    err <- db.put \committee , model
    return cb err if err?
    err <- db.put \committee/last-update , moment.utc!
    return cb err if err?
    cb null
    
    