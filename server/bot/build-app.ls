require! {
    \prelude-ls : { obj-to-pairs, map, join }
}

render-status = (db, $user, name, cb)->
    err, data <- db.get name
    $user[name] = "no any info" if err?
    return cb null if err?
    result =
            data 
                |> obj-to-pairs
                |> map -> "<b>#{it.0}</b> - #{it.1}"
                |> join "\n------\n"
    $user[name] = result
    cb null
module.exports = ({ god-db, ws } )->  ({ db, bot, tanos })->
    export update = (name, $user, cb)->
        render-status db, $user, name , cb
    out$