var JCLToken = artifacts.require('./JCLToken.sol')
var JCLFactory = artifacts.require('./JCLFactory.sol')
var CreateBills = artifacts.require('./CreateBills.sol')

module.exports = function (deployer) {
  deployer.deploy(JCLToken);
  deployer.deploy(JCLFactory);
  deployer.deploy(CreateBills, "0x03", "0x00", 1, 10);
}
