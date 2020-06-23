require! {
    \./handlers.ls
    \prelude-ls : { each, take, map, join }
    \sha256
    \simple-git
    \./bot/extract-chat_ids.ls
    \./bot/send-all-users.ls
}

create-button = (bot, config, bot-step, text)->
        store: "({ $app, $user }, cb)-> $app.updateStep(\"#{bot-step}\", \"#{text}\" , cb)"

perform-notification = (config, bot, message, cb)->
    return cb "expected array of admins" if typeof! config.admins isnt \Array
    err, chat_ids <- extract-chat_ids bot.db, config.admins
    return cb err if err?
    hash = sha256 message
    bot-step = "notification-#{hash}"
    buttons =
        "⚠️ Important"     : create-button bot, config, bot-step, "⚠️ Important"
        "✅ Not Important" : create-button bot, config, bot-step, "✅ Not Important"
    err <- bot.db.put "#{bot-step}:bot-step", { text: "❕ #{message}" , buttons}   
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

wait-seconds = 20

module.exports = (config, bot)->
    cb = ->
    git = simple-git __dirname
    err, log <- git.log
    return cb err if err?
    last10 =
        log.all 
            |> take 10
            |> map -> it.message
            |> join "\n"
    version = log.latest.hash
    <- perform-notification config, bot, "📟 <b>Server is started/restarted</b>\n\n<b>Version</b>\n #{version}.\n\n<b>Latest changes</b>\n#{last10}"
    ms = wait-seconds * 1000
    <- set-timeout _, ms
    setup-checkers config, bot
    
    