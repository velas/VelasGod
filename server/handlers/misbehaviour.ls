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
    model[address] = model[address] ? 0
    model[address] += 1
    err <- db.put method , model
    return cb err if err?
    cb null