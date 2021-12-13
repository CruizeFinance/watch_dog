pragma solidity =0.8.10;

import "./interfaces/KeeperCompatibleInterface.sol";
import "./interfaces/FeedRegistryInterface.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IERC20.sol";



contract StopLoss is KeeperCompatibleInterface {
    uint public counter;

    address public dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private admin;
    
    struct Balance {
        address _token_owner;
        address _token;
        uint256 _amt;
    }
    mapping(address => Balance) public balances;
    
    
    struct AssetInformation {
        address Token_owner;
        address asset_desired;
        address asset_deposited;
        uint256 total_asset_value;
        uint256 dip_amount; // Amount of dip in the asset the user wants to set as a limit below which it'll be swapped with stablecoint
        bool executed;
    }

    event AssetInformationUploadedEvent(
        address Token_owner,
        address asset_desired,
        address asset_deposited,
        uint256 total_asset_value,
        uint256 dip_amount,
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
    address UNI;
    address DAI;
    address BAT;


    // Setting up key so that price feed can be asset agnostic 
    struct PriceFeedKey {
        address _oracle;
    }
    mapping(address => PriceFeedKey) pricekey;

    // 
    constructor() {
        //priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        admin = msg.sender;
        interval = 30;
        lastTimeStamp = block.timestamp;
        counter = 0;

        // Adding Link, wBTc, and ETH support
        // Other supported Assets should be added here 
        
        wBTC = 0xD1B98B6607330172f1D991521145A22BCe793277;
        pricekey[wBTC] = PriceFeedKey(0x6135b13325bfC4B00278B4abC5e20bbce2D6580e);

        link = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;
        pricekey[link] = PriceFeedKey(0x396c5E36DD0a0F5a5D33dae44368D4193f69a1F0);

        wETH = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
        pricekey[wETH] = PriceFeedKey(0x9326BFA02ADD2366b30bacB125260Af641031331);
        
        UNI = 0x075A36BA8846C6B6F53644fDd3bf17E5151789DC;
        pricekey[UNI] = PriceFeedKey(0xDA5904BdBfB4EF12a3955aEcA103F51dc87c7C39);
        
        DAI = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
        pricekey[DAI] = PriceFeedKey(0x777A68032a88E5A84678A77Af2CD65A7b3c0775a);
        
        BAT = 0x2d12186Fbb9f9a8C28B3FfdD4c42920f8539D738;
        pricekey[BAT] = PriceFeedKey(0x8e67A0CFfbbF6A346ce87DFe06daE2dc782b3219);
    }

    // Call chainlink price feed and registry to get price information.
    function getLatestPrice(address _asset) internal view returns (uint256) {
        if(_asset == 0x0000000000000000000000000000000000000000) {
            return uint256(1);
        } else {
            AggregatorV3Interface priceFeed = AggregatorV3Interface(getOracle(_asset));
            (
                uint80 roundID, 
                int price,
                uint startedAt,
                uint timeStamp,
                uint80 answeredInRound
            ) = priceFeed.latestRoundData();
            return uint256(price);
        }
    }

    // Tested: working as expected.
    function getOracle(address _asset) internal view returns(address) {
        address oracle = pricekey[_asset]._oracle;
        return(oracle);
    }


    // Tested: Working as expected 
    function stakeToAAVE(address assetToStake, uint256 _amt) internal returns(bool){
        // For Production: -- 
        //IlendingPoolAddressProvider provider = IlendingPoolAddressProvider(0x88757f2f99175387aB4C6a4b3067c77A695b0349);
        // IlendingPool public lendingPool = ILendingPool(provider.getLendingPool());
    
        // For Kovan TestNet
        IERC20 token = IERC20(assetToStake);
        ILendingPool lendingPool = ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
        token.approve(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe, _amt);
        uint16 referral = 0;
        lendingPool.deposit(address(token), _amt, address(this), referral);
        
        
        return(true);
        // Add conditional so it returns false if there is an error thrown
    }
    
    // Tested: working as expected
    function withdrawfromAAVE(address assetToWithdraw, uint256 _amt, address recipient) internal returns(bool) {
        // For Production
        //IlendingPoolAddressProvider provider = IlendingPoolAddressProvider();
        //IlendingPool public lendingPool = ILendingPool(provider.getLendingPool());

        // For Testing not for Production
        ILendingPool lendingPool = ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
        
        // For production
        lendingPool.withdraw(assetToWithdraw, _amt, recipient);
        
        
        return(true);
        // Add conditional so it returns false if there is an error thrown
    }
    
    
    // Testing: working as expected 
    function swap(
      address _tokenIn, 
      address _tokenOut, 
      uint256 _amountIn, 
      uint256 _amountOutMin,
      address _to
      ) internal returns(bool) {
    // Approve the the Rinkeby Uniswap v2 Router to spend the coins that are held by the smart contract 
      IERC20(_tokenIn).approve(dexRouter, _amountIn);
      //uint _amountOutMin = getAmountOutMin(_tokenIn, _tokenOut, _amountIn);
      
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
      return (true);
      
    }
    

    // Tested: working as expected  
    function getAmountOutMin(
      address _tokenIn, 
      address _tokenOut, 
      uint256 _amountIn
      ) internal view returns (uint256) {
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

    function cancelOrder() internal {
        //TODO: ADD a function where users will be able to cancel their 
        // stop/limit orders, and withdraw deposited funds.
        for (uint i =0; i < stopOrders.length; i++) {
            if(stopOrders[i].Token_owner == msg.sender) {
                delete stopOrders[i];
            }
        }
        for (uint i =0; i < limitOrders.length; i++) {
            if(limitOrders[i].Token_owner == msg.sender) {
                delete limitOrders[i];
            }
        }
    }

  

    // Tested: working as expected 
    function withdraw(uint _amt, address _token) external returns(bool) {
      Balance memory user = balances[msg.sender];
      require(user._amt >= _amt);
      withdrawfromAAVE(_token,_amt,address(this));
      cancelOrder();
      uint newBal = user._amt - _amt;
      IERC20 token = IERC20(_token);
      require(token.transfer(msg.sender, _amt));
      balances[msg.sender] = Balance(user._token_owner, user._token, newBal);
    }
    
    
    // Tested: working as expected 
    function limitBuy_deposit(
      address asset_desired, 
      address asset_deposited, 
      uint total_asset_value, 
      uint dip_amount) external 
        {
        // .approve() must be called from the asset contract directly on the front end!
        require(dip_amount > 0,"dip-amount must be  > 0");
        require(balances[msg.sender]._amt == 0, 'This beta only allows for one order to be open at a time');
        assetInformationCount++;
        IERC20 token = IERC20(asset_deposited);
        
        // Require the transferFrom() function to return true before the value is credited 
        require(
          token.transferFrom(
            msg.sender, 
            address(this), 
            total_asset_value)
        );
        
        // Appendding the users deposited funds and trade details.
        balances[msg.sender] = Balance(msg.sender ,asset_deposited, total_asset_value);
        counter +=1;
        limitOrders.push(AssetInformation(
            msg.sender,
            asset_desired,
            asset_deposited,
            total_asset_value,
            dip_amount,
            false));
        emit AssetInformationUploadedEvent(
          msg.sender, 
          asset_desired, 
          asset_deposited, 
          total_asset_value,
          dip_amount, 
          false, 
          false);
          
         stakeToAAVE(asset_deposited, total_asset_value);
    }

    // Tested Working as expected 
    function stopLoss_deposit(
      address asset_desired,
      address asset_deposited,
      uint total_asset_value,
      uint dip_amount) external 
      {
        // .approve() must be called from the asset contract directly on the front end
        require(dip_amount > 0, 'dip-amount must be >0');
        require(balances[msg.sender]._amt == 0, 'This beta only allows for one order to be open at a time');
        assetInformationCount++;
        IERC20 token = IERC20(asset_deposited);

        // Require that the transferFrom() function to return true before the value is credited
        require(
          token.transferFrom(
            msg.sender,
            address(this),
            total_asset_value)
        );

        //Appendding the accredited  
        balances[msg.sender] = Balance(msg.sender, asset_deposited, total_asset_value);
        stopOrders.push(AssetInformation(
          msg.sender,
          asset_desired,
          asset_deposited,
          total_asset_value,
          dip_amount,
          false)
        );
        emit AssetInformationUploadedEvent(
          msg.sender,
          asset_desired,
          asset_deposited,
          total_asset_value,
          dip_amount,
          false,
          false
        );
        
        stakeToAAVE(asset_deposited, total_asset_value);
      }
      


    // Potentially remove these functions they will error when the orders array is empty
    function checkStop() external view returns(bool) {
        for (uint i=0; i < stopOrders.length; i++) {
            if (stopOrders[i].dip_amount >= getLatestPrice(stopOrders[i].asset_deposited)) {
                return(true);
            }
        }

    }

    function checkLimit() external view returns(bool) {
         for (uint i=0; i < limitOrders.length; i++) {
            if (limitOrders[i].dip_amount >= getLatestPrice(limitOrders[i].asset_desired)) {
                return(true);
            }
        }
    }

   
    function upkeepLimit() internal returns(bool) {
        for (uint i =0; i < limitOrders.length; i++) {
            if (limitOrders[i].dip_amount >= getLatestPrice(limitOrders[i].asset_desired)) {
                
                
                uint amtOut = getAmountOutMin(limitOrders[i].asset_deposited, limitOrders[i].asset_desired,limitOrders[i].total_asset_value);
                
                withdrawfromAAVE(limitOrders[i].asset_deposited, limitOrders[i].total_asset_value, address(this));
                
                
                swap(limitOrders[i].asset_deposited,
                limitOrders[i].asset_desired,
                limitOrders[i].total_asset_value,
                amtOut,
                address(this)
                );
                
                balances[limitOrders[i].Token_owner] = Balance(limitOrders[i].Token_owner, limitOrders[i].asset_desired, amtOut);
                stakeToAAVE(limitOrders[i].asset_desired, amtOut);
                delete limitOrders[i];
                return(true);
            }
        }
    }

      function upkeepStop() internal returns(bool) {
        for (uint i =0; i < stopOrders.length; i++) {
            if (stopOrders[i].dip_amount >= getLatestPrice(stopOrders[i].asset_deposited)) {
                
                withdrawfromAAVE(stopOrders[i].asset_deposited, stopOrders[i].total_asset_value, address(this));
                uint256 amtOut = getAmountOutMin(stopOrders[i].asset_deposited, stopOrders[i].asset_desired ,stopOrders[i].total_asset_value);
                
                swap(stopOrders[i].asset_deposited,
                stopOrders[i].asset_desired,
                stopOrders[i].total_asset_value,
                amtOut,
                address(this)
                );
                
                balances[stopOrders[i].Token_owner] = Balance(stopOrders[i].Token_owner, stopOrders[i].asset_desired, amtOut);
                stakeToAAVE(stopOrders[i].asset_desired, amtOut);
                delete stopOrders[i];
                return(true);
            }
        }
    }

    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;

        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
      lastTimeStamp = block.timestamp;
      upkeepLimit();
      upkeepStop();

      performData;
    }
    function viewOrders(address _address) public view returns(address, address, uint, uint) {
      for(uint i=0; i<stopOrders.length; i++) {
        if(_address == stopOrders[i].Token_owner) {
          return (
            stopOrders[i].asset_desired,
            stopOrders[i].asset_deposited,
            stopOrders[i].total_asset_value,
            stopOrders[i].dip_amount
            );
        }
      }
      for(uint i=0;i<limitOrders.length; i++) {
        if(_address == limitOrders[i].Token_owner) {
          return(
            limitOrders[i].asset_desired,
            limitOrders[i].asset_deposited,
            limitOrders[i].total_asset_value,
            limitOrders[i].dip_amount
          );
        }
      }
    }
  
}
   