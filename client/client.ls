require! {
    \pm2
    \commander : { program }
    \prelude-ls : { find }
    \nodejs-tail : Tail
    \fs : { exists }
    \ws-reconnect : WebSocket
    \./command-handler.ls
    \./send.ls
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

init = (ws, config, cb)->
    return cb "cannot start because config is expected" if typeof! config isnt \Object
    err <- pm2.connect
    return cb err if err?
    err, list <- pm2.list
    return cb err if err?
    node =
        list |> find (.name is config.name)
    return cb err if err?
    return start-later config, cb if not node?
    err, tail <- init-monitoring ws, node
    return cb err if err?
    cb null, tail


program
  .version('0.1.0')
  .option('-n, --name <type>', 'pm2 process name')
  .option('-s, --server <type>', 'server url')
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


    