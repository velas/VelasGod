require! {
    \prelude-ls : { each, obj-to-pairs, map, filter }
    \./handlers.ls
}

polls =
    handlers 
        |> obj-to-pairs 
        |> map (.1.poll) 
        |> filter (?)

make-poll = (connections, db, current)->
    console.log \make-poll, current
    connections |> each (-> it.send current)

make-polls = (connections, db, all, [current, ...rest])->
    make-poll connections, db, current
    <- set-timeout _ , 10000
    group =
        | rest.length is 0 => all
        | _ => rest
    make-polls connections, db, all, group


module.exports = (connections, db)->
    make-polls connections, db, polls, polls