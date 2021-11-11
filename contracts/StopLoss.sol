// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.22 <0.9.0;
pragma solidity ^0.8.0;

 import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

// @title "This contract swaps a given asset with a stablecoin if the users asset value is <= user specified dip_amount"
// @author "Prithviraj Murthy"
// @dev "This smart contract calls the chainlink contract priceFeed to get the latest price of the users asset and based on dip_amount, decides whether or not to swap it"
// @notices "This smart contract accepts a users asset information and calls the chainlink contract priceFeed and based on the user specified dip_amount, decides whether or not to swap it"
// @parameter "user_id, asset_address, total_asset_value, dip_amount"
// @return "A confirmation of whether or not the users asset has been successfully swapped with a stablecoin."


contract StopLoss is KeeperCompatibleInterface {
      uint public counter;
   
    struct AssetInformation {
        uint user_id;
        string asset_address;
        uint total_asset_value;
        uint dip_amount; // Amount of dip in the asset the user wants to set as a limit below which it'll be swapped with stablecoint
    }

    event AssetInformationUploadedEvent(
        uint user_id,
        string asset_address,
        uint total_asset_value,
        uint dip_amount,
        bool created
    );
    mapping(uint => AssetInformation) public assetInformations; 

    FeedRegistryInterface internal registry;
    uint public assetInformationCount = 0; //State variable written to the smart contract
    
    AggregatorV3Interface internal priceFeed;
    //Time interval between price checks for asset information
    uint256 public immutable interval;
    //Last price check time
    uint256 public lastTimeStamp;
    constructor() {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
      
        
        interval = 1;
        lastTimeStamp = block.timestamp;
        counter = 0;
    }

    function createAssetInformation(uint user_id, string memory asset_address, uint total_asset_value, uint dip_amount) public {
        require(dip_amount > 0,"dip-amount must be  > 0");

        assetInformationCount++;

        assetInformations[assetInformationCount] = AssetInformation(user_id, asset_address, total_asset_value, dip_amount);

        emit AssetInformationUploadedEvent(user_id, asset_address, total_asset_value, dip_amount, false);
    }

    // Call chainlink price feed and registry to get price information.
     function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
  

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata /*checkData */
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval; // TODO: Add condition to check if asset value < dip_amount (call getLatestPrice)

    }
   //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        lastTimeStamp = block.timestamp;
        // TODO: Swap if returned True from checkUpKeep.
    }
}