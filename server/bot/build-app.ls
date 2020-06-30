require! {
    \prelude-ls : { obj-to-pairs, map, join, take }
    \cli-truncate
    \as-table
    \./extract-chat_ids.ls
    \./send-all-users.ls
    \moment
    \../handlers/txqueue.ls
    \../handlers/reorg.ls
}

min = (text, num)->
    return text if text.length >= num
    min "#{text} ", num

COL_WIDTH = 50

cut = (text)->
    res = cli-truncate "#{text}", COL_WIDTH, {position: 'middle', preferTruncationOnSpace: true}
    min res, COL_WIDTH

render-status = (db, handlers, $user, name, cb)->
    err, time <- db.get "#{name}/last-update"
    last-update =
        | err? => ""
        | _ => "Last update was #{moment.utc(time).from-now!}\nMax records: 50\n"
    err, data <- db.get name
    $user[name] = "no any info" if err?
    return cb null if err?
    ago =
        moment.utc(time).from-now!
    result =
            data
                |> obj-to-pairs
                |> map -> [it.0, it.1]
                |> take 50
                |> as-table.configure { maxTotalWidth: COL_WIDTH, delimiter: ' | ' }
    $user[name] = "no any info" if result.length is 0
    return cb null if result.length is 0
    $user[name] = "#{last-update}<pre>#{result}</pre>"
    cb null
    
render-status-length = (db, handlers, $user, name, cb)->
    err, time <- db.get "#{name}/last-update"
    last-update =
        | err? => ""
        | _ => "Last update was #{moment.utc(time).from-now!}"
    err, data <- db.get name
    $user["#{name}_length"] = "no any info" if err?
    return cb null if err?
    ago =
        moment.utc(time).from-now!
    result =
            data
                |> obj-to-pairs
                |> map -> [it.0, it.1]
                |> (.length)
    $user["#{name}_length"] = "no any info" if result.length is 0
    return cb null if result.length is 0
    $user["#{name}_length"] = "#{last-update}<pre>#{result}</pre>"
    cb null


    
module.exports = ({ ws, config, handlers, connections } )->  (tanos)->
    { db } = tanos
    export forget_reorg = ($user, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        reorg.forget db, connections, cb  
    export forget_txqueue = ($user, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        txqueue.forget db, connections, cb        
    export clear_txqueue = ($user, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        txqueue.clear-all db, connections, cb
    export update = (name, $user, cb)->
        render-status db, handlers, $user, name , cb
    export update-length = (name, $user, cb)->
        render-status-length db, handlers, $user, name , cb
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