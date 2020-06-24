require! {
    \simple-git
    #\npm-programmatic : npm
    \pm2
    \prelude-ls : { find }
}

update = (cb)->
    console.log \update
    git = simple-git __dirname
    console.log 'pulling changes...'
    err, data <- git.pull
    return cb err if err?
    console.log 'no changes' if data.summary.changes is 0
    return cb null, 'no changes' if data.summary.changes is 0
    err <- pm2.connect
    return cb err if err?
    err, list <- pm2.list
    return cb err if err?
    self =
        list |> find (.name is \monitor)
    console.log 'monitor process is not found' if not self?
    return cb null, 'monitor process is not found' if not self?
    console.log 'trying to restart monitor'
    err <- pm2.restart self
    console.log 'restart err #{err}' if err?
    return cb err if err?
    cb null
    
module.exports = update

#update console.log