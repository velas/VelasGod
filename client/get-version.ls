require! {
    \simple-git
}

get-version = (cb)->
    git = simple-git __dirname
    err, data <- git.log
    return cb err if err?
    version = log.latest.hash
    cb null, version
    
module.exports = get-version

#update console.log