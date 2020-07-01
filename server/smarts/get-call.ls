require! {
    \./velas-api.ls
}
module.exports = (contract, method, params=[])->
    Contract = velas-api![contract]
    return null if not Contract
    to = Contract.address
    Method = Contract[method]
    return null if not Method?
    data = Method.get-data.apply Method, params
    params = { to, data }
    JSON.stringify { jsonrpc :"2.0",id :1, method :"eth_call", params :[ params,"latest"] }