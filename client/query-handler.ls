require! {
    \superagent : { post }
    \./get-config.ls
    \../server/utils/json-parse.ls
}

make-query = (url, method, params=[], cb)->
    query = {
        jsonrpc : \2.0
        id : 1
        method
        params
    }
    err, data <- post url, query .end
    return cb "query err: #{err.message ? err}" if err?
    return cb "expected response object, got #{typeof! data}" if typeof! data isnt \Object
    #err, data <- json-parse data
    return cb "expected object" if typeof! data.body isnt \Object
    return cb data.body.error if data.body?error?
    cb null, data.body.result


module.exports = (ws, node, query, cb)->
    err, model <- json-parse query
    return cb err if err?
    err, config <- get-config node
    return cb err if err?
    err, data <- make-query "http://127.0.0.1:#{config.rpc.port}", model.method, model.params
    #console.log "call of http://127.0.0.1:#{config.rpc.port}, method #{model.method}, params: #{model.params} result", err, data
    return cb err if err?
    cb null, [model.method, JSON.stringify(data), model.id]
    