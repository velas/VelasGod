require! {
    \toml
    \fs : { exists }
    \fs : { read-file }
    
}

module.exports = (node, cb)-> 
    filename = "#{node.pm2_env.pm_cwd}/config.toml"
    file-exists <- exists filename
    return cb "cannot find config.toml" if not file-exists?
    err, content <- read-file filename, 'utf8'
    return cb err if err?
    try
        config = toml.parse content
        cb null, config
    catch err 
        cb err 