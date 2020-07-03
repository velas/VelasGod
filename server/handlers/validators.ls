require! {
    \prelude-ls : { obj-to-pairs, map, unique, maximum, minimum, find, each }
}
#check later
#2020-06-30 21:27:47 UTC Verifier #2 WARN engine  Benign report for validator 0x20c0…cb07 at block 1540147



#2020-06-30 22:34:15 UTC Verifier #1 INFO engine  Signal for transition within contract. New validator list: [0xe60e8b25cfea042789e011c91e171e21932e9768, 0x20c08725e4a286e39e42a74bd080082e43a6cb07, 0x2429e9b9509e87c0ba076c624a8f9ae9bf32b44d, 0xea1e94e41086c11d92bf93577a516f99561a3710, 0x012ab7745fa7b126c3f6a02f1a296f95263cf361, 0xc0b8aaff90c058059bbf5b702b8349ec8dd5cabe, 0xdf506418891adc6465cd7b8819808888c77e0310, 0xd794fb44ef6edb7b9a041b240ec1d2b58debb489, 0x8c34f52d8da544e147003e1e23f7581ef7ac183c, 0x9d4d08646175f12ab1919adf3bfb302bb8bd67fb, 0x9356e9e54d4e24c24644357581bc6680d73af9c3, 0x8d627f775992413234f2e96df879c0bb6041d73a, 0xfa2dab47d4d762ed5c4daf8ec6d1b159171d3ae2, 0xf1075b5eb425cee1cabf73043cd64cd635419fee, 0xfe27c5d54141d7010fb6f7ba2ce8829605ab08f2, 0x4d313487a3e53da4daef86f7659723c258c9f602, 0x8a1a84458f170fa08c085f7e1da5dc7c9be5c0a0, 0xe2e0ab1aba5d8e3b69a391be0481fe4e8cc362af, 0x17a2c03498c04ec260fb2fdb5df3f0b3d2aa1df3]
#2020-06-30 17:44:51 UTC Verifier #0 TRACE engine  Current validator set: SimpleList { validators: [0xe60e8b25cfea042789e011c91e171e21932e9768, 0xd794fb44ef6edb7b9a041b240ec1d2b58debb489, 0x9356e9e54d4e24c24644357581bc6680d73af9c3, 0xfa2dab47d4d762ed5c4daf8ec6d1b159171d3ae2, 0x9d4d08646175f12ab1919adf3bfb302bb8bd67fb, 0xc0b8aaff90c058059bbf5b702b8349ec8dd5cabe, 0xf1075b5eb425cee1cabf73043cd64cd635419fee, 0x17a2c03498c04ec260fb2fdb5df3f0b3d2aa1df3, 0x20c08725e4a286e39e42a74bd080082e43a6cb07, 0x9a18b823005f5695577af32fc9722571c1ea265e, 0xfe27c5d54141d7010fb6f7ba2ce8829605ab08f2, 0xdf506418891adc6465cd7b8819808888c77e0310, 0x55ba6f0b67a0471a41b0c9067c1e0ff94715e43d, 0x8c34f52d8da544e147003e1e23f7581ef7ac183c, 0xea1e94e41086c11d92bf93577a516f99561a3710, 0x8d627f775992413234f2e96df879c0bb6041d73a, 0x7e49fcf26097d16e6775d7c5a2ae2b8063a22a6a, 0xa64d579ec6d939c455ac025ff30c5766df48f203, 0x2429e9b9509e87c0ba076c624a8f9ae9bf32b44d] }

parse-list1 = (message, cb)->
    try 
        r = message.match(/\[([^\[]+)\]/)
        return cb \cannot-parse if not r?
        console.log message, r
        cb null, r.1.split(',').map(-> it.trim!)
    catch err
        console.log \parse-error, err, message
        cb err

extract-block = (message, cb)->
    return parse-list1(message.message, cb) if message.type is \INFO and message.message.index-of('New validator list') > -1
    return parse-list1(message.message, cb) if message.type is \TRACE and message.message.index-of('Current validator set: SimpleList') > -1
    cb "pass"

module.exports = (db, ws, message)->
    cb = ->
    err, validators <- extract-block message
    return cb null if err?
    err, data <- db.get \validators
    model = if err? then {} else data
    validators |> each (-> model[it.0] = it.1)
    err <- db.put \validators , model
    return cb err if err?
    cb null

