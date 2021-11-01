const StopLoss = artifacts.require("./StopLoss.sol");

module.exports = function(deployer) {
  deployer.deploy(StopLoss);
};
