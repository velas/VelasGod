try-parse = (str, cb)->
    try
        cb null, JSON.parse(str)
    catch err 
        cb err
        
module.exports = try-parse