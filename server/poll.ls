require! {
    \prelude-ls : { each, obj-to-pairs, map, filter }
    \./handlers.ls
}

polls =
    handlers 
        |> obj-to-pairs 
        |> map (.1.poll) 
        |> filter (?)

make-poll = (connections, current)->
    connections |> each (-> it.send current)

make-polls = (connections, all, [current, ...rest])->
    make-poll connections, current
    <- set-timeout _ , 10000
    group =
        | rest.length is 0 => all
        | _ => rest
    make-polls connections, all, group


module.exports = (connections)->
    make-polls connections, polls, polls