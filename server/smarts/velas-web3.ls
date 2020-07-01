require! {
    \web3 : Web3
}
#security updates (TODO check more)
#
#networks =
#    mainnet: \https://mainnet-v2.velas.com/rpc
#    testnet: \https://testnet-v2.velas.com/rpc
module.exports = ->
    web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1"))
    delete web3.eth.send-transaction
    delete web3.eth.send-signed-transaction
    delete web3.eth.send-raw-transaction
    delete web3.personal
    delete web3.eth.accounts
    delete web3.eth.getAccounts
    delete web3.eth.sign
    #web3.eth.provider-url = network
    web3