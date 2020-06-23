require! {
    \./handlers.ls
    \prelude-ls : { each }
    \sha256
}

extract-chat_ids = (db, [username, ...usernames], cb)->
    return cb null, [] if not username?
    err, chat_id_guess <- db.get "#{username}:username"
    chat_ids =
        | err? => []
        | _ => [chat_id_guess]
    err, rest <- extract-chat_ids db, usernames
    return cb err if err?
    all = chat_ids ++ rest
    cb null, all

send-all-users = (bot, [chat_id, ...chat_ids], bot-step, cb)->
    return cb null if not chat_id?
    console.log chat_id
    console.oo
    err <- bot.send-user chat_id, bot-step
    return cb err if err?
    <- set-immediate
    send-all-users bot, chat_ids, bot-step, cb

perform-notification = (config, bot, message, cb)->
    return cb "expected array of admins" if typeof! config.admins isnt \Array
    err, chat_ids <- extract-chat_ids bot.db, config.admins
    return cb err if err?
    hash = sha256 message
    bot-step = "notification-#{hash}"
    err <- bot.db.put "#{bot-step}:bot-step", { text: "‼️ #{message}" }
    return cb err if err?
    err <- send-all-users bot, chat_ids, bot-step
    return cb err if err?
    console.log \notification, message
    cb null

already-notified = {}

notify-all-users = (config, index, bot, err, cb)->
    already-notified[index] = already-notified[index] ? {}
    checker = already-notified[index]
    if checker[err]? and checker[err] > 0
       checker[err] -= 1
       return cb null
    checker[err] = 20
    perform-notification config, bot, err, cb

check = (config, bot, handlers)-> (func)->
    cb = ->
    index = handlers.index-of func
    return cb null if typeof! func.check isnt \Function
    err <- func.check bot.db
    return notify-all-users config, index, bot, err, cb if err?
    delete already-notified[index]
    cb null

check-all-info = (handlers, config, bot)->
    handlers |> each check config, bot, handlers


setup-checkers = (config, bot)->
    check-all-info handlers, config, bot
    <- set-timeout _, 2000
    setup-checkers config, bot

wait-seconds = 10

module.exports = (config, bot)->
    #<- perform-notification config, bot, "📟 Server is started/restarted. It will run all checkers in #{wait-seconds} seconds to reduce inacurate data. All nodes should report all necessary info in that period otherwise they are too slow "
    ms = wait-seconds * 1000
    <- set-timeout _, ms
    setup-checkers config, bot
    
    