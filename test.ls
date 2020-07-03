require! {
    \web3-eth-accounts : Web3EthAccounts
}




account = new Web3EthAccounts('ws://localhost:8546')
acc = account.privateKeyToAccount("0xB66BB50C81664472CB50D3FDEB8A074A8832725C79A2D6ED2AD439DF1E692225")

console.log acc

console.log acc.sign("test").signature


console.log \recover,  account.recover("test", acc.sign("test").signature, "")

#> {
#  address: '0x2c7536E3605D9C16a7a3D7b1898e529396a65c23',
#  privateKey: '0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318',
#  signTransaction: function(tx){...},
#  sign: function(data){...},
#  encrypt: function(password){...}
#}