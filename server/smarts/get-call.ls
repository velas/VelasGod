require! {
    \./velas-api.ls
}
module.exports = (contract, method, params=[], request_id)->
    Contract = velas-api![contract]
    return null if not Contract
    to = Contract.address
    Method = Contract[method]
    return null if not Method?
    data = Method.apply(Method, params).get-data!
    params = { to, data }
    JSON.stringify { jsonrpc :"2.0",id : request_id, method :"eth_call", params :[ params,"latest"] }