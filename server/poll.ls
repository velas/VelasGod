require! {
    \prelude-ls : { each }
}

polls =
    * \cpu_usage
    * \freemem
    * \uptime 
    * \platform
    * \diskusage
    * JSON.stringify { method: \net_Peers }

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