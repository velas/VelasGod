require! {
    \pm2
    \commander : { program }
    \prelude-ls : { find }
    \nodejs-tail : Tail
    \fs : { exists }
    \ws-reconnect : WebSocket
    \./command-handler.ls
    \./send.ls
    \web3-eth-accounts : Web3EthAccounts
}

start-later = (config, cb)->
    console.log "waiting for the running #{config.name} process"
    <- set-timeout _, 10000
    start config, cb



process-line-builder = (ws, node)-> (line)->
    err <- send ws, line
    console.log err if err?
    
init-monitoring = (ws, node, cb)->
    path = node.pm2_env.pm_err_log_path
    command-handler ws, node
    return cb "expected log path" if typeof! path isnt \String
    tail = new Tail path, { persistent: yes }
    process-line = process-line-builder ws, node
    tail.on \line , process-line
    #tail.on('close',  (line)-> process.stdout.write(line))
    cb null, tail

try-get-all-info = (config, cb)->
    return cb "process #{name} not found" if config.name?
    return cb "config.log_path is required" if not config.log_path?
    return cb "config.process_location is required" if not config.process_location?
    node =
        pm2_env :
            pm_err_log_path: config.log_path
            pm_cwd: config.process_location
        private_key: config.private_key
    cb null, node

get-node = (config, cb)->
    err <- pm2.connect
    return try-get-all-info config, cb if err?
    err, list <- pm2.list
    return cb err if err?
    node =
        list |> find (.name is config.name)
    if node? 
        node.private_key = config.private_key
    if node?private_key?
        account = new Web3EthAccounts('ws://localhost:8546')
        acc = account.privateKeyToAccount(node.private_key)
        console.log \YOUR_ADDRESS, acc.address
    return cb null, node if node?
    try-get-all-info config, cb

init = (ws, config, cb)->
    return cb "cannot start because config is expected" if typeof! config isnt \Object
    err, node <- get-node config
    return start-later config, cb if not node?
    err, tail <- init-monitoring ws, node
    return cb err if err?
    cb null, tail


program
  .version('0.1.0')
  .option('-n, --name <type>', 'pm2 process name')
  .option('-s, --server <type>', 'server url')
  .option('-l, --log_path <type>', 'if to skip --name you can define log_path, process_location explicetelly')
  .option('-c, --process_location <type>', 'if to skip --name you can define log_path, process_location explicetelly')
  .option('-p, --private_key <type>', 'monitoring agent authorization key')
  .parse process.argv

ws = new WebSocket program.server

err, tail <- init ws, program

ws.start!

ws.on \reconnect , ->
    tail.close!
    console.log 'trying to reconnect to the God...'

ws.on \connect , ->
    console.log 'connected to the God and start to pray'
    tail.watch!


    