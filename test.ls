require! {
    \web3 : Web3
}


web3 = new Web3!


console.log web3.eth.accounts.sign("test", '0xB66BB50C81664472CB50D3FDEB8A074A8832725C79A2D6ED2AD439DF1E692225')