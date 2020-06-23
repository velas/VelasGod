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
    
module.exports = extract-chat_ids