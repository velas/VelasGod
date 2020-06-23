send-all-users = (bot, [chat_id, ...chat_ids], bot-step, cb)->
    return cb null if not chat_id?
    return cb "bot.send-user expected to be a funciton" if typeof! bot.send-user isnt \Function
    err <- bot.send-user chat_id, bot-step
    return cb err if err?
    <- set-immediate
    send-all-users bot, chat_ids, bot-step, cb
module.exports = send-all-users