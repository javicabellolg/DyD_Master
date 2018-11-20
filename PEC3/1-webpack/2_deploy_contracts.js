var ConvertLib = artifacts.require('./ConvertLib.sol')
var MetaCoin = artifacts.require('./MetaCoin.sol')
var JCLToken = artifacts.require('./JCLToken.sol')
var JCLMain = artifacts.require('./JCLMain.sol')
var JCLFactory = artifacts.require('./JCLFactory.sol')
var CreateBills = artifacts.require('./CreateBills.sol')

module.exports = function (deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.link(ConvertLib, JCLToken);
  deployer.deploy(MetaCoin);
  deployer.deploy(JCLToken).then(function() {
    return deployer.deploy(JCLMain, JCLToken.address)
  });
  deployer.deploy(JCLFactory);
  deployer.deploy(CreateBills, "0x03", "0x00", 1, 10);
}
