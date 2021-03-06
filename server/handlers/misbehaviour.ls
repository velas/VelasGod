require! {
    \prelude-ls : { keys, values }
    \moment
}

method = \misbehaviour

#2020-06-30 21:29:26 UTC Verifier #0 TRACE engine  validator set recording benign misbehaviour at block #1540166 by 0x9a18b823005f5695577af32fc9722571c1ea265e
#2020-06-30 21:29:26 UTC Verifier #0 WARN engine  Benign report for validator 0x9a18…265e at block 1540166
#2020-06-30 21:31:00 UTC Verifier #2 TRACE engine  validator set recording benign misbehaviour at block #1540184 by 0x9a18b823005f5695577af32fc9722571c1ea265e
#2020-06-30 21:31:01 UTC Verifier #2 WARN engine  Benign report for validator 0x9a18…265e at block 1540184
#2020-06-30 21:32:36 UTC Verifier #2 TRACE engine  validator set recording benign misbehaviour at block #1540202 by 0x9a18b823005f5695577af32fc9722571c1ea265e
#2020-06-30 21:32:36 UTC Verifier #2 WARN engine  Benign report for validator 0x9a18…265e at block 1540202
#2020-06-30 21:33:15 UTC Verifier #3 TRACE engine  validator set recording benign misbehaviour at block #1540209 by 0xa64d579ec6d939c455ac025ff30c5766df48f203
#2020-06-30 21:33:16 UTC Verifier #3 WARN engine  Benign report for validator 0xa64d…f203 at block 1540209
#2020-06-30 21:34:10 UTC Verifier #2 TRACE engine  validator set recording benign misbehaviour at block #1540219 by 0x9a18b823005f5695577af32fc9722571c1ea265e

module.exports = (db, ws, message)->
    cb = ->
    return cb null if message.type isnt \TRACE or message.message.index-of('validator set recording benign misbehaviour at block') is -1
    err, name <- db.get "ws/#{ws.id}"
    return cb err if err?
    err, data <- db.get method
    model = if err? then {} else data
    #console.log \misbehaviour , message.message, message.message.match('by (0x.+)')
    address = message.message.match('by (0x.+)')?1
    err, mining_address_guess <- db.get \mining_address
    mining_address = mining_address_guess ? {}
    vs = values mining_address
    ks = keys mining_address
    index = vs.index-of(address)
    name = 
        | index is -1 => address
        | _ => ks[index]
    model[name] = model[name] ? 0
    model[name] += 1
    if model[name] and model[address]?
        model[name] = model[name] + model[address]
        delete model[address]
    err <- db.put method , model
    return cb err if err?
    err <- db.put \misbehaviour/last-update , moment.utc!
    return cb err if err?
    cb null