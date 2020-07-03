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
    \web3-eth-accounts : Web3EthAccounts
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
    cb null, ["DISK","#{info.available / 1024  / 1024 / 1024 }"]

module.exports = (ws, node)->
    make-log = (type, message, id)->
        time = moment.utc!.format('YYYY-MM-DD HH:mm:ss') + ' UTC'
        "#{time} Monitor ##{id ? 0} #{type} #{message}"
    
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
    
    requests = { cpu_usage, freemem, uptime, platform, diskusage, config, external_ip, update, version, auth }
    
    auth = ([name, value])->
        return if not node.private_key?
        account = new Web3EthAccounts('ws://localhost:8546')
        acc = account.privateKeyToAccount(node.private_key)
        result = acc.sign(value).signature
        cb null, ["AUTH", result]
    
    ws.on \message , (data)->
        rpc = (cb)->
            query-handler ws, node, data, cb
        get-info = 
            | data.index-of('auth') > -1 => auth data.split('_')
            | _ => requests[data] ? rpc
        err, data <- get-info
        message =
            | err? => make-log \ERROR , "for request #{data} #{err}"
            | _ => make-log(data.0, data.1, data.2)
        err <- send ws, message
        console.log "server is offline" if err?

    