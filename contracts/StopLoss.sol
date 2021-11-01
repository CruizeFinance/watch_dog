// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract StopLoss {
    uint public assetInformationCount = 0; //State variable written to the smart contract

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

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Kovan
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }

    function createAssetInformation(uint user_id, string memory asset_address, uint total_asset_value, uint dip_amount) public {
        assetInformationCount ++;
        assetInformations[assetInformationCount] = AssetInformation(user_id, asset_address, total_asset_value, dip_amount);
        emit AssetInformationUploadedEvent(user_id, asset_address, total_asset_value, dip_amount, false);
    }

    /**
     * Returns the latest price
     */
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

}