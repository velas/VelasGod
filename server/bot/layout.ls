check-access = 
     "$app.can-read($user, $check)" : "no-access"


module.exports = 
    "main:bot-step":
        redirect-condition: check-access
        text: 
            "Welcome to VelasGod Bot"
            "This Bot provides information about velas blockchain health"
        menu:
            "ℹ️ Home" : "goto:general-info"
    "no-access:bot-step" : 
        text: "You have no access. Please contact to Velas dev group"
    "general-info:bot-step" : 
        redirect-condition: check-access
        text: "Get Information about <b>nodes</b>"
        buttons:
            "⚠️ Notifications" : "goto:notifications"
            "📟 Make Request" : "goto:request"
            "⏫ Consensus" : "goto:consensus"
            "🕑 Last Activity": "goto:node-last-activity"
            "🚦 Is Syncing" : "goto:eth_syncing"
            "📡 Networking": "goto:networking"
            "📶 Hardware" : "goto:resources"
            "📩 Pending" : "goto:pending"
            "📝 Software" : "goto:soft"
            "📝 Configuration" : "goto:configuration"
    "notifications:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('problem', $user, cb)"
        text: "{{{$user.problem}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('problem', $user, cb)"
            "Forget": 
                goto: "issues"
                store: "({ $app, $user }, cb)-> $app.forget($user,'problem', cb)"
    "request:bot-step" : 
        redirect-condition: check-access
        text: "📟 Make request to all nodes via RPC. Please wait for result. Nodes should return it later"
        buttons: 
            "Epoch" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'stakingEpoch',[], cb)"
            "Get Pools" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'getPools',[], cb)"
            "Get Pools Inactive" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'getPoolsInactive',[], cb)"  
            "Get Pools To Be Elected" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'getPoolsToBeElected',[], cb)"                  
            "Ban Counter" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'ValidatorSet', 'banCounter',[], cb)" 
            "Pending Validators" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'ValidatorSet', 'getPendingValidators',[], cb)"   
            "Current Validators" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'ValidatorSet', 'getValidators',[], cb)"   
            "MAX_VALIDATORS" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'ValidatorSet', 'MAX_VALIDATORS',[], cb)"   
            "Previous Validators" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'ValidatorSet', 'getPreviousValidators',[], cb)"   
            "Pools To Be Removed" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'getPoolsToBeRemoved',[], cb)"   
            "MAX_CANDIDATES" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'MAX_CANDIDATES',[], cb)" 
            "Epoch Duration" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'stakingEpochDuration',[], cb)"  
            "Epoch End Block" :
                goto: "eth_call-performed"
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'Staking', 'stakingEpochEndBlock',[], cb)"
            "Allowed Consensus Change" :
                goto: "eth_call-performed" 
                store: "({ $app, $user }, cb)-> $app.eth_call($user, 'ValidatorSet', 'initiateChangeAllowed',[], cb)"
    "eth_call-performed:bot-step" : 
        redirect-condition: check-access
        text: "Eth Call is performed. Sent RPC Request to {{$user.eth_call_length}} nodes. Nodes should send response back in {{$user.eth_call_wait}} seconds. After that deadline you will see the report"
    "eth_call:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('eth_call', $user, cb)"
        text: "Eth Call Result\n{{{$user.eth_call}}}"    
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('eth_call', $user, cb)"
            "Last Response": 
                store: "({ $app, $user }, cb)-> $app.download('eth_call_last_update', $user, cb)"
    "consensus:bot-step" :
        redirect-condition: check-access
        text: "Consensus information"
        buttons:
            "📶 Heights": "goto:node-height"
            "🚯 Misbehaviour" : "goto:misbehaviour"
            "🏪 Committee": "goto:committee"
            "🔀 Reorgs": "goto:reorgs"
            "📝 Mining addresses" : "goto:mining_address"
            "📝 Staking addresses" : "goto:staking_address"
            "📝 Is Pool Active" : "goto:is_pool_active"
            
    "misbehaviour:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('misbehaviour', $user, cb)"
        text: "{{{$user.misbehaviour}}}"
    "posdao_Staking_stakingEpoch:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('posdao_Staking_stakingEpoch', $user, cb)"
        text: "{{{$user.posdao_Staking_stakingEpoch}}}"         
    "committee:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('committee', $user, cb)"
        text: "{{{$user.committee}}}" 
        buttons:
            "Repeat": 
                goto: "committee"
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('committee', $user, cb)"
    "is_pool_active:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('is_pool_active', $user, cb)"
        text: "{{{$user.is_pool_active}}}" 
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('is_pool_active', $user, cb)"
    "mining_address:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('mining_address', $user, cb)"
        text: "{{{$user.mining_address}}}" 
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('mining_address', $user, cb)"
    "staking_address:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('staking_address', $user, cb)"
        text: "{{{$user.staking_address}}}" 
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('staking_address', $user, cb)"
    "eth_syncing:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('eth_syncing', $user, cb)"
        text: "{{{$user.eth_syncing}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('eth_syncing', $user, cb)"
    "configuration:bot-step" : 
        redirect-condition: check-access
        text: "Get Information about configuration"
        buttons:
            "🩸 Min Gas Price" : "goto:parity_minGasPrice"
            "📛 Transaction Limit" : "goto:parity_transactionsLimit"
            "🔗 Chain" : "goto:parity_chain"
            "🔘 Chain Status" : "goto:parity_chainStatus"
    "parity_minGasPrice:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_minGasPrice', $user, cb)"
        text: "{{{$user.parity_minGasPrice}}}"
    "parity_chain:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_chain', $user, cb)"
        text: "{{{$user.parity_chain}}}"
    "parity_chainStatus:bot-step" : 
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_chainStatus', $user, cb)"
        text: "{{{$user.parity_chainStatus}}}"
    "parity_transactionsLimit:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_transactionsLimit', $user, cb)"
        text: "{{{$user.parity_transactionsLimit}}}"
    "pending:bot-step" : 
        redirect-condition: check-access
        text: "Get Information about pending transactions"
        buttons:
            "📛 Rejected (TOP 50)" : "goto:txqueue"
            "📛 Rejected Length" : "goto:txqueue_length"
            "🗄 Pending list (max 100)" : "goto:pending-txs"
            "📨 Pending stats" : "goto:pending-stats"
            "📩 Unsigned txs" : "goto:unsigned-txs"
    "txqueue:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('txqueue', $user, cb)"
        text: "{{{$user.txqueue}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('txqueue', $user, cb)"
            "Forget All": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget_txqueue($user, cb)"
            "Delete All": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.clear_txqueue($user, cb)"
    "txqueue_length:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.updateLength('txqueue', $user, cb)"
        text: "{{{$user.txqueue_length}}}"
        buttons:
            "Forget All": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget_txqueue($user, cb)"
            "Delete All": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.clear_txqueue($user, cb)"
    "action-performed:bot-step" :
        redirect-condition: check-access
        text: "Your action is performed"
    "pending-txs:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_pendingTransactions', $user, cb)"
        text: "This indicator never returned the valuable result. But lets keep it for learning\n{{{$user.parity_pendingTransactions}}}"
    "pending-stats:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_pendingTransactionsStats', $user, cb)"
        text: "This indicator never returned the valuable result. But lets keep it for learning\n{{{$user.parity_pendingTransactionsStats}}}"
    "unsigned-txs:bot-step" :
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_unsignedTransactionsCount', $user, cb)"
        text: "This indicator never returned the valuable result. But lets keep it for learning\n{{{$user.parity_unsignedTransactionsCount}}}"
    "networking:bot-step" : 
        redirect-condition: check-access
        text: "Get Information networking <b>node hardware</b>"
        buttons:
            "🔭 Net Listening" : "goto:net_listening"
            "📡 Connected Peers": "goto:peers"
            "📡 Last import from Peers": "goto:peers_log"
            "🏳 Enodes" : "goto:enodes"
            "🏳 Enode IPs" : "goto:enode_ips"
    "net_listening:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('net_listening', $user, cb)"
        text: "{{{$user.net_listening}}}"
        buttons: 
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'net_listening', cb)"
    "resources:bot-step" : 
        redirect-condition: check-access
        text: "Get Information about <b>node hardware</b>"
        buttons:
            "💻 PLATFORM": "goto:platform"
            "🆒 USED CPU": "goto:cpu"
            "🆓 FREEMEM": "goto:freemem"
            "⤵️ AVAILABLE DISK": "goto:disk"
            "🆙 UPTIME": "goto:uptime"
    "soft:bot-step" : 
        redirect-condition: check-access
        text: "Get Information about <b>soft</b>"
        buttons:
            "🏳 Node modes" : "goto:modes"
            "🃏 Node kinds" : "goto:kinds"
            "👁 Monitor Version": "goto:monitor-version"
            "👁 Monitor Address": "goto:monitor-address"
            "💻 Node Version": "goto:node-version"
    "kinds:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_nodeKind', $user, cb)"
        text: "{{{$user.parity_nodeKind}}}"
        buttons: 
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'parity_nodeKind', cb)"
    "enodes:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_enode', $user, cb)"
        text: "{{{$user.parity_enode}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('parity_enode', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'parity_enode', cb)"
    "enode_ips:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_enode_ip', $user, cb)"
        text: "{{{$user.parity_enode_ip}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('parity_enode_ip', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'parity_enode_ip', cb)"
    "modes:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('parity_mode', $user, cb)"
        text: "This indicator always returns active. But lets keep it for learning\n{{{$user.parity_mode}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('parity_mode', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'parity_mode', cb)"
    "monitor-version:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('version', $user, cb)"
        text: "{{{$user.version}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('version', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'version', cb)"
    "monitor-address:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('AUTH', $user, cb)"
        text: "{{{$user.AUTH}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('AUTH', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'AUTH', cb)"
    "node-version:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('nodeversion', $user, cb)"
        text: "{{{$user.nodeversion}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('nodeversion', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'nodeversion', cb)"
    "platform:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('platform', $user, cb)"
        text: "{{{$user.platform}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('platform', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'platform', cb)"
    "cpu:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('cpu', $user, cb)"
        text: "Not sure about correctness of this indicator\n{{{$user.cpu}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('cpu', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'cpu', cb)"
    "freemem:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('freemem', $user, cb)"
        text: "Not sure about correctness of this indicator\n{{{$user.freemem}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('freemem', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'freemem', cb)"
    "disk:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('disk', $user, cb)"
        text: "{{{$user.disk}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('disk', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'disk', cb)"
    "uptime:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('uptime', $user, cb)"
        text: "{{{$user.uptime}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('uptime', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'uptime', cb)"
    "node-height:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('height', $user, cb)"
        text: "{{{$user.height}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('height', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'height', cb)"
    "node-last-activity:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('lastActivity', $user, cb)"
        text: "{{{$user.lastActivity}}}"
    "reorgs:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('reorg', $user, cb)"
        text: "{{{$user.reorg}}}"
        buttons:
            "Forget All": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget_reorg($user, cb)"
    "peers:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('peers', $user, cb)"
        text: "{{{$user.peers}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('peers', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'peers', cb)"
    "peers_log:bot-step":
        redirect-condition: check-access
        on-enter: "({ $app, $user }, cb)-> $app.update('peer_log', $user, cb)"
        text: "{{{$user.peer_log}}}"
        buttons:
            "Download": 
                store: "({ $app, $user }, cb)-> $app.download('peer_log', $user, cb)"
            "Forget": 
                goto: "action-performed"
                store: "({ $app, $user }, cb)-> $app.forget($user,'peer_log', cb)"