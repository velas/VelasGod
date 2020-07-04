require! {
    \prelude-ls : { obj-to-pairs, map, join, take, unique, each }
    \cli-truncate
    \as-table
    \./extract-chat_ids.ls
    \./send-all-users.ls
    \moment
    \../handlers/txqueue.ls
    \../handlers/reorg.ls
    \../handlers/eth_call.ls : eth_call_handler
    \../smarts/get-call.ls
    \fs
    \../get-request-id.ls
}

min = (text, num)->
    return text if text.length >= num
    min "#{text} ", num

COL_WIDTH = 50

cut = (text)->
    res = cli-truncate "#{text}", COL_WIDTH, {position: 'middle', preferTruncationOnSpace: true}
    min res, COL_WIDTH

get-result-array = (data, cb)->
    res =
        data
            |> join "\n...\n"
            |> -> "<pre>#{it}</pre>"
    cb null, res
get-result = (data, cb)->
        return get-result-array data, cb if typeof! data is \Array
        result =
            data
                |> obj-to-pairs
                |> map -> [it.0, it.1]
        return cb null, "" if result.length is 0
        values =
            result
                |> map -> "#{it.1}"
        keys =
            result
                |> map -> it.0
                |> join "\n"
        return cb null, "The same value:\n\n<b>#{values.0}</b>\n\nfor\n#{keys}" if unique(values).length is 1 
        items = 
            result
                |> take 50
                |> as-table.configure { maxTotalWidth: COL_WIDTH, delimiter: ' | ' }
                |> -> "<pre>#{it}</pre>"
        cb null, items
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
    err, result <- get-result data
    return cb err if err?
    $user[name] = "no any info" if result.length is 0
    return cb null if result.length is 0
    $user[name] = "#{last-update}#{result}"
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
    export forget = ($user, what, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        err <- db.put what, {}
        return cb err if err?
        cb null
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
    export download = (name, $user, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        err, data <- db.get name
        return cb err if err?
        filename = "./tmp/#{name}.txt"
        err <- fs.write-file filename , JSON.stringify(data, null, 4)
        return cb err if err?
        document = fs.createReadStream(filename)
        <- tanos.bot.send-document { $user.chat_id, document  }
    export eth_call = ($user, contract, method, params, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        request_id = get-request-id!
        request = get-call contract, method, params, request_id
        return cb "method not found" if not request?
        #console.log { request_id, request }
        eth_call_handler.invoked["Monitor ##{request_id}"] = { contract, method, params }
        err <- db.put \eth_call , {}
        return cb err if err?
        connections |> each (-> it.send request)
        cb null
        <- set-timeout _, 5000
        <- tanos.send-user $user.chat_id, \eth_call
    out$