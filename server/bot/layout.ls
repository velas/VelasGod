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
            "📶 Resources" : "goto:resources"
    "resources:bot-step" : 
        text: "Get Information about <b>node hardware</b>"
        buttons:
            "💻 PLATFORM": "goto:platform"
            "🆒 CPU": "goto:cpu"
            "🆓 FREEMEM": "goto:freemem"
            "⤵️ DISK": "goto:disk"
            "🆙 UPTIME": "goto:uptime"
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