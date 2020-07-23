require! {
    \prelude-ls : { each, obj-to-pairs, map, filter }
    \./handlers.ls
}

polls =
    handlers 
        |> obj-to-pairs 
        |> filter (.1.priority isnt \low)
        |> map (.1.poll) 
        |> filter (?)

invoke-poll = (current, db, connections, cb)->
    current { db, connections }, cb

make-poll = (connections, db, current, cb)->
    return invoke-poll current, db, connections, cb if typeof! current is \Function
    connections |> each (-> it.send current)
    cb null

make-polls = (connections, db, all, [current, ...rest])->
    <- make-poll connections, db, current
    <- set-timeout _ , 10000
    group =
        | rest.length is 0 => all
        | _ => rest
    make-polls connections, db, all, group


module.exports = (connections, db)->
    make-polls connections, db, polls, polls