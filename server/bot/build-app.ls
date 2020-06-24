require! {
    \prelude-ls : { obj-to-pairs, map, join }
    \cli-truncate
    \as-table
    \./extract-chat_ids.ls
    \./send-all-users.ls
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
    $user[name] = "no any info" if result.length is 0
    return cb null if result.length is 0
    $user[name] = "<pre>#{result}</pre>"
    cb null
    
    
module.exports = ({ ws, config } )->  (tanos)->
    { db } = tanos
    export update = (name, $user, cb)->
        render-status db, $user, name , cb
    export updateStep = (bot-step, text, cb)->
        err, step <- db.get "#{bot-step}:bot-step"
        return cb err if err?
        delete step.buttons
        step.text = "#{step.text}\n\n#{text}"
        err <- db.put "#{bot-step}:bot-step", step
        return cb err if err?
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        err <- send-all-users tanos, chat_ids, bot-step
        return cb err if err?
        cb null
    out$