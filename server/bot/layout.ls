module.exports = 
    "main:bot-step":
        text: 
            "Welcome to VelasGod Bot"
            "This Bot provides information about velas blockchain health"
        menu:
            "ℹ️ General Info" : "goto:general-info"
    "general-info:bot-step" : 
        text: "Get Information about <b>nodes</b>"
        buttons:
            "⏫ Heights": "goto:node-height"
            "🕑 Last Activity": "goto:node-last-activity"
            "🔀 Reorgs": "goto:reorgs"
            "📡 Networking": "goto:networking"
            "📶 Performance" : "goto:resources"
            "📩 Unsigned txs" : "goto:unsigned-txs"
            "📝 Soft" : "goto:soft"
    
    "unsigned-txs:bot-step" :
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_unsignedTransactionsCount', $user, cb)"
        text: "{{{$user.parity_unsignedTransactionsCount}}}"
    "networking:bot-step" : 
        text: "Get Information networking <b>node hardware</b>"
        buttons:
            "📡 Peers": "goto:peers"
            "🏳 Enodes" : "goto:enodes"
            "🏳 Enode IPs" : "goto:enode_ips"
    "resources:bot-step" : 
        text: "Get Information about <b>node hardware</b>"
        buttons:
            "💻 PLATFORM": "goto:platform"
            "🆒 CPU": "goto:cpu"
            "🆓 FREEMEM": "goto:freemem"
            "⤵️ DISK": "goto:disk"
            "🆙 UPTIME": "goto:uptime"
    "soft:bot-step" : 
        text: "Get Information about <b>soft</b>"
        buttons:
            "🏳 Node modes" : "goto:modes"
            "🃏 Node kinds" : "goto:kinds"
            "👁 Monitor Version": "goto:monitor-version"
            "💻 Node Version": "goto:node-version"
    "kinds:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_nodeKind', $user, cb)"
        text: "{{{$user.parity_nodeKind}}}"
    "enodes:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_enode', $user, cb)"
        text: "{{{$user.parity_enode}}}"
    "enode_ips:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_enode_ip', $user, cb)"
        text: "{{{$user.parity_enode_ip}}}"
    "modes:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_mode', $user, cb)"
        text: "{{{$user.parity_mode}}}"
    "monitor-version:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('version', $user, cb)"
        text: "{{{$user.version}}}"
    "node-version:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('nodeversion', $user, cb)"
        text: "{{{$user.nodeversion}}}"
    "platform:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('platform', $user, cb)"
        text: "{{{$user.platform}}}"
    "cpu:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('cpu', $user, cb)"
        text: "{{{$user.cpu}}}"
    "freemem:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('freemem', $user, cb)"
        text: "{{{$user.freemem}}}"
    "disk:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('disk', $user, cb)"
        text: "{{{$user.disk}}}"
    "uptime:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('uptime', $user, cb)"
        text: "{{{$user.uptime}}}"
    "node-height:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('height', $user, cb)"
        text: "{{{$user.height}}}"
    "node-last-activity:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('lastActivity', $user, cb)"
        text: "{{{$user.lastActivity}}}"
    "reorgs:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('reorg', $user, cb)"
        text: "{{{$user.reorg}}}"
    "peers:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('peers', $user, cb)"
        text: "{{{$user.peers}}}"