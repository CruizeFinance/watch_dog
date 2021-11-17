pragma solidity =0.8.7;

// Chainlink Keeper and Chainlink Interface
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";



interface ILendingPool {
  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(
      address indexed reserve, 
      address indexed user, 
      address indexed to, 
      uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );
  event Swap(address indexed reserve, address indexed user, uint256 rateMode);
  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);
  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);
  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);
  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );
  event Paused();
  event Unpaused();
  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);

  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  function rebalanceStableBorrowRate(address asset, address user) external;

  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;

  function setReserveInterestRateStrategyAddress(
      address reserve,
       address rateStrategyAddress
    ) external;

  function setConfiguration(address reserve, uint256 configuration) external;
  function getReserveNormalizedIncome(address asset) external view returns (uint256);
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);
  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;

  function getReservesList() external view returns (address[] memory);
  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);
  function setPause(bool val) external;
  function paused() external view returns (bool);
}

interface ILendingPoolAddressesProvider {
  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
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
        address Token_owner;
        address asset_desired;
        address asset_deposited;
        uint total_asset_value;
        uint dip_amount; // Amount of dip in the asset the user wants to set as a limit below which it'll be swapped with stablecoint
        bool executed;
    }

    event AssetInformationUploadedEvent(
        address Token_owner,
        address asset_desired,
        address asset_deposited,
        uint total_asset_value,
        uint dip_amount,
        bool executed,
        bool created
    );
    mapping(address => AssetInformation) public assetInformations; 
    AssetInformation[] public limitOrders;
    AssetInformation[] public stopOrders;
    
    FeedRegistryInterface internal registry;
    uint public assetInformationCount = 0; //State variable written to the smart contract
    
    
    //Time interval between price checks for asset information
    uint256 public immutable interval;
    //Last price check time
    uint256 public lastTimeStamp;
    
    address wBTC;
    address wETH;
    address link;


    // Setting up key so that price feed can be asset agnostic 
    struct PriceFeedKey {
        address _oracle;
    }
    mapping(address => PriceFeedKey) pricekey;

    // 
    constructor() {
        //priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        admin = msg.sender;
        interval = 1;
        lastTimeStamp = block.timestamp;
        counter = 0;

        // Adding Link, wBTc, and ETH support
        // Other supported Assets should be added here 
        wBTC = 0xe0C9275E44Ea80eF17579d33c55136b7DA269aEb;
        pricekey[wBTC] = PriceFeedKey(0x6135b13325bfC4B00278B4abC5e20bbce2D6580e);

        link = 0xa36085F69e2889c224210F603D836748e7dC0088;
        pricekey[link] = PriceFeedKey(0x396c5E36DD0a0F5a5D33dae44368D4193f69a1F0);

        wETH = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
        pricekey[wETH] = PriceFeedKey(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }

    // Call chainlink price feed and registry to get price information.
    function getLatestPrice(address _asset) public view returns (int) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(getOracle(_asset));
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    // Fetches the  asset oracle address given the asset.
    function getOracle(address _asset) internal view returns(address) {
        address oracle = pricekey[_asset]._oracle;
        return(oracle);
    }

    /*
    Allows the user to create a limit buy order and deposit the 
    funds they wish to use to place the limit buy order.
    @params - asset_address: The address of the stable coins that you are depositing.
    @params - total_asset_value: The amount of stable coins you wish to use to place the buy order
    @params - dip_amount: the price of the limit order you would like to place. 
    */
    function limitBuy_deposit(address asset_desired, address asset_deposited, uint total_asset_value, uint dip_amount) public 
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
        counter +=1;
        orders.push(AssetInformation(
            msg.sender,
            asset_desired,
            asset_deposited,
            total_asset_value,
            dip_amount,
            false));
        emit AssetInformationUploadedEvent(msg.sender, asset_desired, asset_deposited, total_asset_value, dip_amount, false, false);
    }

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata /*checkData */
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // TODO: Add condition to check if asset value < dip_amount (call getLatestPrice)

        if(checkStop()) {
            return(true);
        } else if (checkLimit())  {
            return(true);
        } else {
            return(false);
        }



    }

   //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        lastTimeStamp = block.timestamp;
        // TODO: Swap if returned True from checkUpKeep.
    }

    // Testing needed 
    function upkeepStop() external returns(bool) {
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].dip_amount <= getLatestPrice(orders[i].asset_deposited)){
                uint memory amtOut = getAmountOutMin(orders[i].asset_deposited, orders[i].asset_desired, orders[i].total_asset_value);

                require(
                    swap(order[i].asset_deposited, 
                    orders[i].asset_desired, 
                    orders[i].total_asset_value,
                    amtOut,
                    address(this)
                    )
                );
                assetInformations[orders[i].Token_owner] = AssetInformation(orders[i].token, null, orders[i].asset_desired, amtOut, true);
                stakeToAAVE(orders[i].asset_desired, amtOut);
                delete orders[i];
                return(true);
            }
        }
    }

    // Testing needed
    function upkeepLimit() external returns(bool) {
        for (uint i =0; i < stopOrders.length; i++) {
            if (stopOrders[i].dip_amount >= getLatestPrice(stopOrders[i].asset_desired)) {
                require(
                    // Implement function to withdraw assets that have been stakes 
                    // before the execution of the limit order.
                );
                uint memory amtOut = getAmountOutMin(stopOrders[i].asset_desired, stopOrders[i].asset_deposited, stopOrders[i].total_asset_value);

                require(
                    swap(stopOrders[i].asset_deposited,
                    stopOrders[i].asset_desired,
                    stopOrders[i].total_asset_value,
                    amtOut,
                    address(this)
                    )
                );
                assetInformations[stopOrders[i].Token_onwer] = AssetInformation(stopOrder[i].Token_owner, null, stopOrders[i].asset_desired, amtOut, true);
                stakeToAAVE(orders[i].asset_desired, amtOut);
                delete stopOrders[i];
                return(true);
            }
        }
    }


    function checkStop() external returns(bool) {
        for (uint i=0; i < limitOrder.length; i++) {
            if (stopOrders[i].dip_amount <= getLatestPrice(stopOrders[i].asset_desired)) {
                return(true);
            }
        }

    }

    function checkLimit external returns(bool) {
         for (uint i=0; i < limitOrder.length; i++) {
            if (stopOrders[i].dip_amount >= getLatestPrice(stopOrders[i].asset_desired)) {
                return(true);
            }
        }
    }
    
    function stakeToAAVE(address assetToStake, uint256 _amt) internal {
        // For Production: -- 
        // IlendingPoolAddressProvider provider = IlendingPoolAddressProvider();
        // IlendingPool public lendingPool = ILendingPool(provider.getLendingPool());
    
        // For Kovan TestNet
        IERC20 token = IERC20(assetToStake);
        ILendingPool lendingPool = ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
        token.approve(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe, _amt);
        uint16 referral = 0;
        lendingPool.deposit(address(token), _amt, address(this), referral);
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

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) internal {
    // Approve the the Rinkeby Uniswap v2 Router to spend the coins that are held by the smart contract 
    IERC20(_tokenIn).approve(dexRouter, _amountIn);
    
    // Logic for the optimal path of the swap
    address[] memory path;
        if (_tokenIn == wETH || _tokenOut == wETH) {
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        } else {
        path = new address[](3);
        path[0] = _tokenIn;
        path[1] = wETH;
        path[2] = _tokenOut;
        }
        // Calling the swap function from the uniswap V2 router contract on Rinkeby 
        IUniswapV2Router(dexRouter).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }
    


    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {
        // Logic to get the optimal path for the swap
        address[] memory path;
        if (_tokenIn == wETH || _tokenOut == wETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = wETH;
            path[2] = _tokenOut;
        }
        // Calling the .getAmountsOut() univswap v2 router contract 
        uint256[] memory amountOutMins = IUniswapV2Router(dexRouter).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  
}