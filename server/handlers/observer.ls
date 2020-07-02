require! {
    \prelude-ls : { each }
}

module.exports = (db, ws, message)->
    observers =  module.exports.observers[message.type]
    return if typeof! observers isnt \Array
    observers |> each (-> it null, message)
    
module.exports.observers = {}

module.exports.on = (type, cb)->
    module.exports.observers[type] =  module.exports.observers[type] ? []
    module.exports.observers[type].push cb

module.exports.off = (type, cb)->
    observers =  module.exports.observers[message.type]
    return if typeof! observers isnt \Array
    index = observers.index-of cb
    return if index is -1
    observers.splice index, 1
    
    