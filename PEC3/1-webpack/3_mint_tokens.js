const JCLToken = artifacts.require('./JCLToken.sol');

module.exports = function (deployer, network, accounts) {
	console.log('la red es la siguiente');
	console.log(network);
	switch (network) {
	case 'ganache':
		mintTokensForGanache(accounts);
		break;
	
	default:
		throw new Error ('No minting function defined for this network');
	}
};

async function mintTokensForGanache (accounts) {
	const token = await JCLToken.deployed();
	token.mint(accounts[5], 10000);
	token.mint(accounts[6], 10000);

	console.log('Minting tokens to Ganache accounts');
}
