require! {
    \ws : WebSocket
    \./config.json
    \./handle-message.ls
    \./poll.ls
}

wss = new WebSocket.Server config

connections = []

poll connections

remove-ws = (ws)-> ->
  index = connections.index-of ws 
  return if index is -1
  connections.splice index, 1

uuidv4 = ->
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace //[xy]//g, (c) ->
    r = Math.random! * 16 .|. 0
    v = if c is 'x' then r else r .&. 3 .|. 8
    v.toString 16

wss.on \connection , (ws)->
  connections.push ws
  ws.id = uuidv4!
  ws.on \message , handle-message(ws)
  ws.on \close , remove-ws(ws)
  <- set-timeout _, 1000
  ws.send \config
console.log "Started server on port", config.port