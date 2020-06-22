module.exports = 
    "main:bot-step":
        text: 
            "Welcome to VelasGod Bot"
            "This Bot provides information about velas blockchain health"
        menu:
            "General Info" : "goto:general-info"
    "general-info:bot-step" : 
        text: "Get Information about <b>nodes</b>"
        buttons:
            "Heights": "goto:node-height"
            "Last Activity": "goto:node-last-activity"
            "Reorgs": "goto:reorgs"
    "node-height:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('height', $user, cb)"
        text: "{{{$user.height}}}"
    "node-last-activity:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('lastActivity', $user, cb)"
        text: "{{{$user.lastActivity}}}"
    "reorgs:bot-step":
        on-enter: "({ $app, $user }, cb)-> $app.update('reorg', $user, cb)"
        text: "{{{$user.reorg}}}"