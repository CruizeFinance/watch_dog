# Watch_Dog
This is a version==0 smart contract that contains a minimum viable version of our sophisticated hedging system.

<br>
<b>watch_dog</b> is the most eminent weapon of cruize finance, or more specifically, a hedged kingdom for its inhabitants assets.

<br>

### watch_dog is a smart contract that binds a users asset with 3 layers:
<li> Price floor protection 
<li> Yield Generation on hedged asset
<li> Release of either hedged asset or the price floor value of the asset in USDC, at the time of withdrawal.

<br>

### How does the smart contract work?
The hedged asset along with the price floor is stored in the contract sturcture. <br>

As an when the assets value increases, the price floor adjusts to the 85% of the current(increased) asset value in the market. <br>

An upkeep task scheduled uses Chainlinks price feed registry/Oracle to get price information of an asset at a constant interval. <br>

The asset is pushed to the AAVE lending protocol to generate a constant yield for the time it stays in our contract. <br>

When the user returns to the protocol to withdraw their hedged asset, the protocol decides whether the asset can be returned to the user as is, depending on whether the asset is above the price floor or below it. <br>


<br>
Framework of the Smart Contract: <i>Truffle</i>

<br>

## Integrations

#### Chainlink
<li> To get price information of an asset. <br>
<li> Certain amount of LINK tokens are added for our contract on the chainlink upkeep registry to facilitate un-interrupted calls from our smart contract. <br>

#### AAVE lending Protocol
<li> The users hedged asset is immediately staked at the AAVE lending protocol to generate a stable Yield. <br>

