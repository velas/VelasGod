require! {
    \../get-request-id.ls
    \../handlers/eth_call.ls : eth_call_handler
    \../smarts/get-call.ls
}

module.exports = ({ contract, method, params=[], name, handler}, cb)->
    return cb "contract is required" if not contract?
    return cb "method is required" if not method?
    request_id = get-request-id!
    request = get-call contract, method, params, request_id
    return cb "method not found" if not request?
    eth_call_handler.invoked["Monitor ##{request_id}"] = { contract, method, params, name, handler }
    cb null, request
        
    

