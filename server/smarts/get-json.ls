require! {
    \./velas-api.ls
    \prelude-ls : { find, map }
}
module.exports = (contract, method, params=[])->
    method =
        velas-api!.abis[contract]
            |> find (.name is method)
    return null if not method?
    types =
        method
    types