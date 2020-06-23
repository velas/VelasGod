require! {
    \simple-git
    #\npm-programmatic : npm
    \pm2
    \prelude-ls : { find }
}

update = (cb)->
    git = simple-git __dirname
    err, data <- git.pull
    return cb err if err?
    return cb null, 'no changes' if data.summary.changes is 0
    err <- pm2.connect
    return cb err if err?
    err, list <- pm2.list
    return cb err if err?
    self =
        list |> find (.name is \monitor)
    return cb null, 'monitor process is not found' if not self?
    err <- pm2.restart self
    return cb err if err?
    cb null
    
module.exports = update

#update console.log