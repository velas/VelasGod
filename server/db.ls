require! {
    \fs : { read-file, write-file, exists }
}

cache = {}

export put = (name, model, cb)->
    cache[name] = model
    data = JSON.stringify model, null, 4
    err <- write-file "./data/#{name}.json", data
    return cb err if err?
    cb null
    
export get = (name, cb)->
    return cb null, cache[name] if cache[name]?
    file-exists <- exists "./data/#{name}.json"
    return cb "not exists" if not file-exists
    err, data <- read-file "./data/#{name}.json", \utf8
    return cb err if err?
    model = JSON.parse data
    cache[name] = model
    cb null, model