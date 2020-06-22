module.exports = (ws, data, cb)->
    try
        ws.send data
        cb null
    catch err
        cb err