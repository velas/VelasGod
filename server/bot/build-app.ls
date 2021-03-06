require! {
    \prelude-ls : { obj-to-pairs, map, join, take, unique, each, keys, pairs-to-obj }
    \cli-truncate
    \as-table
    \./extract-chat_ids.ls
    \./send-all-users.ls
    \moment
    \../handlers/txqueue.ls
    \../handlers/reorg.ls
    \../smarts/get-call.ls
    \fs
    \../utils/make-call.ls
}

min = (text, num)->
    return text if text.length >= num
    min "#{text} ", num

COL_WIDTH = 50

cut = (text)->
    res = cli-truncate "#{text}", COL_WIDTH, {position: \middle , preferTruncationOnSpace: true}
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
    err, result <- get-result data
    return cb err if err?
    $user[name] = "no any info" if result.length is 0
    return cb null if result.length is 0
    $user[name] = "#{name}\n#{last-update}#{result}"
    cb null
    
render-status-length = (db, handlers, $user, name, cb)->
    err, time <- db.get "#{name}/last-update"
    last-update =
        | err? => ""
        | _ => "Last update was #{moment.utc(time).from-now!}"
    err, data <- db.get name
    $user["#{name}_length"] = "no any info" if err?
    return cb null if err?
    result =
            data
                |> obj-to-pairs
                |> map -> [it.0, it.1]
                |> (.length)
    $user["#{name}_length"] = "no any info" if result.length is 0
    return cb null if result.length is 0
    $user["#{name}_length"] = "#{name}\n#{last-update}\n<pre>#{result}</pre>"
    cb null

    
module.exports = ({ ws, config, handlers, connections } )->  (tanos)->
    { db } = tanos
    export can-read = ($user, $check)->
        cb = (err, result)->
            $check.result = 
                | err? => yes
                | _ => result
        err, chat_ids <- extract-chat_ids db, config.readers
        return cb err if err?
        result = $user.chat_id not in chat_ids
        cb null, result
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
        str = JSON.stringify(data, null, 4)
        err <- fs.write-file filename , str
        return cb err if err?
        document = filename
        #console.log \fun, tanos.bot.send-document
        <- tanos.bot.send-document { $user.chat_id, document  }
    export eth_call = ($user, contract, method, params, cb)->
        err, chat_ids <- extract-chat_ids db, config.admins
        return cb err if err?
        return cb "not allowed" if $user.chat_id not in chat_ids
        err, request <- make-call { contract, method, params }
        return cb err if err?
        err, data <- db.get \lastActivity
        return cb err if err?
        expecting = 
            data 
                |> keys
                |> map -> [it, "..."]
                |> pairs-to-obj
        err <- db.put \eth_call_last_update , expecting
        return cb err if err?
        err <- db.put \eth_call , expecting
        return cb err if err?
        connections |> each (-> it.send request)
        $user.eth_call_length = connections.length
        $user.eth_call_wait = 3
        cb null
        seconds =  $user.eth_call_wait * 1000
        <- set-timeout _, seconds
        <- tanos.send-user $user.chat_id, \eth_call
    out$