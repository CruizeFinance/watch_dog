// Using mocha for solidity tests
// Can use chaijs for javascript tests

const StopLoss = artifacts.require('./StopLoss.sol')

contract('StopLoss', (accounts) => {
    before(async () =>{
        this.stopLoss = await StopLoss.deployed()
    })

    it('deploys successfully', async () =>{
        const address =await this.stopLoss.address

        assert.notEqual(address, 0x0)
        assert.notEqual(address, '')
        assert.notEqual(address, null)
        assert.notEqual(address, undefined)
    })

    it('Create AssetInformation', async () =>{
        const result = await this.stopLoss.createAssetInformation(1, "0x9326BFA02ADD2366b30bacB125260Af641031331", 100, 150)
        console.log('Result:', result)
        
    })
})
