require! {
  \prelude-ls : { each }
  \./handlers/observer.ls
  \./get-request-id.ls
}

mempool = {}

random-one = (connections)->
  connections.0

build-rpc = (type, build-method)->
    observer.on build-method , (err, message)->
        console.log build-method, message
        cb = mempool[message.role]
        return if typeof! func isnt \Function
        delete mempool[message.role]
        cb null, message.message
    (body, cb)->
        return cb "expected body object" if typeof! body isnt \Object
        #{"jsonrpc":"2.0","id":1,"method":"eth_sendRawTransaction","params":["0xf869288255f0830f424094bffe028201b9606d17af410870ea9e6e6890bbd487038d7ea4c68000801ba0694a918706b9fabf4d730cfa51ce48989e98fbd9ee0d17de4a89e48d1fdc57b6a02461b8874a6a96e15aa514ac31d108d564c98ddd214be84d5472cc7e919f95b5"]}
        { jsonrpc, id, method, params } = body
        return cb "expected jsonrpc is 2.0" if jsonrpc isnt \2.0
        return cb "expected id is 1" if id isnt 1
        return cb "expected method eth_sendRawTransaction" if method isnt build-method
        return cb "expected array with one string element in params" if typeof! params isnt \Array or typeof! params.0 isnt \String
        id = get-request-id!
        mempool["Monitor ##{id}"] = cb
        request = JSON.stringify { jsonrpc, id, method, params }
        applied-connections =
            | type is \random => [random-one(connections)]
            | _ => connections
        applied-connections |> each (-> it.send request)
    
eth_getBalance             = build-rpc \random, \eth_getBalance
eth_getTransactionCount    = build-rpc \random, \eth_getTransactionCount
net_version                = build-rpc \random, \net_version
eth_estimateGas            = build-rpc \random, \eth_estimateGas
eth_getTransactionReceipt  = build-rpc \random, \eth_getTransactionReceipt
eth_gasPrice               = build-rpc \random, \eth_gasPrice
eth_sendRawTransaction     = build-rpc \all,    \eth_sendRawTransaction

rpc = { 
  eth_getBalance, 
  eth_getTransactionCount , 
  net_version , 
  eth_estimateGas,
  eth_getTransactionReceipt,
  eth_gasPrice,
  eth_sendRawTransaction
}

module.exports = (connections, app)->
    app.post \/rpc , (req, res)->
      method = rpc[req.body.method]
      return res.status(400).end("Method #{req.body.method} is not available") if typeof! method isnt \Function
      err, data <- method req.body
      return res.status(400).end("#{err}") if err?
      res.send data