require! {
    \prelude-ls : { obj-to-pairs, map, join }
    \cli-truncate
    \as-table
}

min = (text, num)->
    return text if text.length >= num
    min "#{text} ", num

COL_WIDTH = 50

cut = (text)->
    res = cli-truncate "#{text}", COL_WIDTH, {position: 'middle', preferTruncationOnSpace: true}
    min res, COL_WIDTH

render-status = (db, $user, name, cb)->
    err, data <- db.get name
    $user[name] = "no any info" if err?
    return cb null if err?
    result =
            data 
                |> obj-to-pairs
                |> map -> [it.0, it.1]
                |> as-table.configure { maxTotalWidth: COL_WIDTH, delimiter: ' | ' }
    $user[name] = "<pre>#{result}</pre>"
    cb null
module.exports = ({ god-db, ws } )->  ({ db, bot, tanos })->
    export update = (name, $user, cb)->
        render-status db, $user, name , cb
    out$