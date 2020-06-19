require! {
    \moment
    \os-utils : os
    \diskusage : disk
    \os : os2
    \toml
    \fs : { exists }
    \external-ip : getIP
    \fs : { read-file }
    
}

external_ip = (cb)->
    get = getIP!
    err, ip <- get  
    return cb err if err?
    cb null, ip

cpu_usage = (cb)->
    v <- os.cpu-usage
    cb null, ["CPU",v]

freemem = (cb)->
    v <- os.freememPercentage
    cb null, ["FREEMEM",v]

uptime = (cb)->
    v <- os.sysUptime
    cb null, ["UPTIME",v]


platform = (cb)->
    v <- os.platform
    cb null, ["PLATFORM",v]    

diskusage = (cb)->
    path = if os2.platform! is 'win32' then 'c:' else '/'
    err, info <- disk.check path
    return cb err if err?
    cb null, ["DISK","#{info.available} / #{info.free} / #{info.total}"]

module.exports = (ws, node)->
    make-log = (type, message)->
        time = moment.utc!.format('YYYY-MM-DD hh:mm:ss') + ' UTC'
        "#{time} Monitor #0 #{type} #{message}"
    
    config = (cb)-> 
        filename = "#{node.pm2_env.pm_cwd}/config.toml"
        file-exists <- exists filename
        return cb "cannot find config.toml" if not file-exists?
        err, content <- read-file filename, 'utf8'
        return cb err if err?
        try
            config = toml.parse content
            cb null, ["CONFIG", JSON.stringify(config)]
        catch err 
            cb err 
    

    
    requests = { cpu_usage, freemem, uptime, platform, diskusage, config, external_ip }
    
    
    ws.on \message , (data)->
        console.log \message, data
        info = requests[data]
        return if typeof! info isnt \Function
        err, data <- info 
        return ws.send make-log "INFO", "ERROR for request #{data} #{err}" if err?
        ws.send make-log data.0, data.1

    