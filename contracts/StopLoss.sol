// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.22 <0.9.0;
pragma solidity ^0.8.0;

// Chainlink Keeper and Chainlink Interface
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";


// Imports for interfacing with the AAVE lending protocol. 
import 'https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPoolAddressesProvider.sol';
import 'https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPool.sol';

interface IaToken {
    function balanceOf(address _user) external view returns (uint256);
    function redeem(uint _amount) external;
}

interface IAaveLendingPool {
    function deposit(
        address _reserve,
        uint256 _amount, 
        uint16 _referralCose
        ) external;
}


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// Import Interface for Uniswap / other clone.
interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}



// @title "This contract swaps a given asset with a stablecoin if the users asset value is <= user specified dip_amount"
// @author "Prithviraj Murthy"
// @dev "This smart contract calls the chainlink contract priceFeed to get the latest price of the users asset and based on dip_amount, decides whether or not to swap it"
// @notices "This smart contract accepts a users asset information and calls the chainlink contract priceFeed and based on the user specified dip_amount, decides whether or not to swap it"
// @parameter "Token_onwer, asset_address, total_asset_value, dip_amount"
// @return "A confirmation of whether or not the users asset has been successfully swapped with a stablecoin."


contract StopLoss is KeeperCompatibleInterface {
    uint public counter;

    address public dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private admin;
   
    struct AssetInformation {
<<<<<<< Updated upstream
        address Token_onwer;
        string asset_address;
=======
        address Token_owner;
        address asset_desired;
        address asset_deposited;
>>>>>>> Stashed changes
        uint total_asset_value;
        uint dip_amount; // Amount of dip in the asset the user wants to set as a limit below which it'll be swapped with stablecoint
        bool executed;
    }

    event AssetInformationUploadedEvent(
<<<<<<< Updated upstream
       address Token_onwer,
        string asset_address,
=======
        address Token_owner,
        address asset_desired,
        address asset_deposited,
>>>>>>> Stashed changes
        uint total_asset_value,
        uint dip_amount,
        bool executed,
        bool created
    );
    mapping(address => AssetInformation) public assetInformations; 

    FeedRegistryInterface internal registry;
    uint public assetInformationCount = 0; //State variable written to the smart contract
    
    AggregatorV3Interface internal priceFeed;
    //Time interval between price checks for asset information
    uint256 public immutable interval;
    //Last price check time
    uint256 public lastTimeStamp;


    constructor() {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        admin = msg.sender;
        interval = 1;
        lastTimeStamp = block.timestamp;
        counter = 0;
    }

    /*
    Allows the user to create a limit buy order and deposit the 
    funds they wish to use to place the limit buy order.
    @params - asset_address: The address of the stable coins that you are depositing.
    @params - total_asset_value: The amount of stable coins you wish to use to place the buy order
    @params - dip_amount: the price of the limit order you would like to place. 
    */
    function limitBuy_deposit(string memory asset_desited, string memory asset_deposited, uint total_asset_value, uint dip_amount) public 
        {
        // .approve() must be called from the asset contract directly on the front end!
        require(dip_amount > 0,"dip-amount must be  > 0");
        assetInformationCount++;
        IERC20 token = IERC20(asset_deposited);
        
        // Require the transferFrom() function to return true before the value is credited 
        require(token.transferFrom(msg.sender, address(this), total_asset_value),
        'Token Transfer Failure');
        
        // Appendding the users deposited funds and trade details.
        assetInformations[msg.sender] = AssetInformation(msg.sender, asset_desired ,asset_deposited, total_asset_value, dip_amount, false);
        emit AssetInformationUploadedEvent(msg.sender, asset_desired, asset_deposited, total_asset_value, dip_amount, false, false);
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
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // TODO: Add condition to check if asset value < dip_amount (call getLatestPrice)
        for(uint i=0;  i < assetInformations.lenght; i++) {

        } 

    }
   //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        lastTimeStamp = block.timestamp;
        // TODO: Swap if returned True from checkUpKeep.
        
    }


    function swapLimitBuy(address token1 ) {
        // TODO: Follow up to see what is the deal with the dex 
    }

    function checkLimit() external returns(bool) {
        //TODO: 
    }

    /*
    Allows the User to stake their funds to the AAVE protocol and earn yield.
    */
    function stakeToAAVE(address assetToStake, uint256 _amt) internal {
        // For Production: -- 
        // IlendingPoolAddressProvider provider = IlendingPoolAddressProvider();
        // IlendingPool public lendingPool = ILendingPool(provider.getLendingPool());
    
        // For Kovan TestNet
        IERC20 token = IERC20(assetToStake);
        ILendingPool lendingPool = ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
        token.approve(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe, _amt);
        uint16 referral = 0;
        lendingPool.deposit(address(USDT), _amt, address(this), referral);
    }

    function withdrawfromAAVE(address assetToWithdraw, uint256 _amt, address recipient) external {
        // For Production
        //IlendingPoolAddressProvider provider = IlendingPoolAddressProvider();
        //IlendingPool public lendingPool = ILendingPool(provider.getLendingPool());

        // For Testing not for Production
        ILendingPool lendingPool = ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
        
        // For production
        lendingPool.withdraw(assetToWithdraw, _amt, recipient);
    }






  

}