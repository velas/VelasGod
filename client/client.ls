require! {
    \pm2
    \commander : { program }
    \prelude-ls : { find }
    \nodejs-tail : Tail
    \fs : { exists }
    \ws-reconnect : WebSocket
    \./command-handler.ls
}

start-later = (cb)->
    console.log \wait-for-process
    <- set-timeout _, 10000
    start cb

url = \ws://explorer-staking.velas.com/monitor
#debug
url = \ws://localhost:1234

ws = new WebSocket url

ws.start!

ws.on "reconnect", ->
    console.log("reconnecting")

ws.on \open, ->
    console.log \connected-to-server

process-line-builder = (node)-> (line)->
    ws.send line
    
start-monitoring = (node, cb)->
    console.log \start-monitoring
    path = node.pm2_env.pm_err_log_path
    command-handler ws, node
    return cb "expected log path" if typeof! path isnt \String
    tail = new Tail path, { persistent: yes }
    process-line = process-line-builder node
    tail.on \line , process-line
    #tail.on('close',  (line)-> process.stdout.write(line))
    tail.watch!
    cb null

start = (config, cb)->
    err <- pm2.connect
    return cb err if err?
    err, list <- pm2.list
    return cb err if err?
    node =
        list |> find (.name is config.name)
    return cb err if err?
    return start-later cb if not node?
    err <- start-monitoring node
    return cb err if err?
    cb null

program
  .version('0.1.0')
  .option('-n, --name <type>', 'pm2 process name')
  .parse(process.argv)

err <- start program
    