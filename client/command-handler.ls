require! {
    \moment
    \os-utils : os
    \diskusage : disk
    \os : os2
    \toml
    \fs : { exists }
    \external-ip : getIP
    \fs : { read-file }
    \./send.ls
    \./get-config.ls
    \./update-self.ls
    \./query-handler.ls
    \./get-version.ls
    
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
    v = os.freememPercentage!
    cb null, ["FREEMEM",v]

uptime = (cb)->
    v = os.sysUptime!
    cb null, ["UPTIME",v]


platform = (cb)->
    v = os.platform!
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
        err, config <- get-config node
        return cb err if err?
        cb null, ["CONFIG", JSON.stringify(config)]
    
    update = (cb)->
        err, data <- update-self
        return cb err if err?
        cb null, ["UPDATE", JSON.stringify(data)]
    version = (cb)->
        err, data <- get-version
        return cb err if err?
        cb null, ["VERSION", JSON.stringify(data)]
    requests = { cpu_usage, freemem, uptime, platform, diskusage, config, external_ip, update, version }
    
    ws.on \message , (data)->
        info = requests[data]
        return query-handler ws, node, data if typeof! info isnt \Function
        err, data <- info 
        console.log err, data
        message =
            | err? => make-log \ERROR , "for request #{data} #{err}"
            | _ => make-log(data.0, data.1)
        err <- send ws, message
        console.log "server is offline" if err?

    