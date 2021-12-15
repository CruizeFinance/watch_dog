const IERC20 = artifacts.require("IERC20");
const Cruize = artifacts.require("Main");
const whale = "0x036b96eea235880a9e82fb128e5f6c107dfe8f57";
const _usdc = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const wBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
const wETH ="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const link = "0x514910771AF9Ca656af840dff83E8264EcF986CA";
const uni = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
const dai = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const aUSDC = "0xBcca60bB61934080951369a648Fb03DF4F96263C";

/*
ganache-cli --fork https://mainnet.infura.io/v3/4d1481d1a4c04cb4a9646260001f072f --unlock 0x036b96eea235880a9e82fb128e5f6c107dfe8f57 -p 7545
*/
contract("IERC20", (accounts) => {
    it("Get LP balance of Unlocked Account", async () => {
        const LP = await IERC20.at(_usdc);
        const bal = await LP.balanceOf(whale);
        console.log(`The unlocked account has a balance of: ${bal} LP tokens`);
    });
    // Giving the admin the LP token required to deposit. 
    it("Should transfer LP tokens from the unlocked account to our contract Admin", async() => {
        const LP = await IERC20.at(_usdc);
        const bal = await LP.balanceOf(whale);
        await LP.transfer(accounts[0], bal, {from: whale});
        console.log(`The admin account now has a balance of ${await LP.balanceOf(accounts[0])} LP tokens`);
    });
});

contract("Cruize", (accounts) => {
    // Testinf contract deployment
    it("Should Deploy", async () => {
        testInstance = await Cruize.new(
            accounts[0]
        );
        console.log(testInstance.address);
    });

    it('Should Return the latest price feeds', async () => {
        console.log(`WBTC current price is: ${await testInstance.getLatestPrice(wBTC, {from: accounts[0]})}`);
        console.log(`wETH current price is: ${await testInstance.getLatestPrice(wETH, {from: accounts[0]})}`);
        console.log(`dai current price is: ${await testInstance.getLatestPrice(dai, {from: accounts[0]})}`);
        console.log(`link current price is: ${await testInstance.getLatestPrice(link, {from: accounts[0]})}`);
    });

    it('should place an order that is executed immediately', async () => {
        const USDC = await IERC20.at(_usdc);

        const LP = await IERC20.at(_usdc);
        const ball = await LP.balanceOf(whale);
        await LP.transfer(accounts[0], ball, {from: whale});
        console.log(`The admin account now has a balance of ${await LP.balanceOf(accounts[0])} LP tokens`);

    
        const bal = await LP.balanceOf(accounts[0]);
        
        await USDC.approve(testInstance.address, 218556885763014 ,{from: accounts[0]});
        const asset_desired = wBTC;
        const asset_deposited = _usdc;
        const assetValue = bal;
        const dipAmount = 5817979000000;

        await testInstance.limitBuy_deposit(asset_desired, asset_deposited, 21599763014, 5817979000000, {from: accounts[0]});
        const ausdc = await IERC20.at(aUSDC);
        console.log(`The smart contract has a current balance of ${await ausdc.balanceOf(testInstance.address, {from: accounts[0]})} aUSDC`);
    });

    it("Should simulate upkeep on the smart contract", async () => {
        await testInstance.upkeepLimit({from: accounts[0]});
        const ausdc = await IERC20.at(aUSDC);
        console.log(`The smart contract has a current balance of ${await ausdc.balanceOf(testInstance.address, {from: accounts[0]})} aUSDC`);
        const aBTC = await IERC20.at("0x9ff58f4fFB29fA2266Ab25e75e2A8b3503311656");
        console.log(`The smart contract has a current balance of ${await aBTC.balanceOf(testInstance.address, {from: accounts[0]})} aBTC`);  
    });

    
});
