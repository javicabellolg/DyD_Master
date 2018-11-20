pragma solidity 0.4.24;

import "./Ownable.sol";
import "./JCLToken.sol";

contract createBills_bckp is Ownable{

    uint16 convRate = 1;
    JCLToken public jcltoken;

    event billRegister (uint billId, uint billAmount, address billRequest);

    struct Bill {
        uint id;
        uint amount;
        address ownerSupply;
    }

    Bill[] public bills;

    mapping (address => Bill) public ownerBill;

    constructor(address _client, address _supplyerAddress, uint _id, uint _amount) public {
            owner = _client;
            ownerBill[_client].id = _id;
            ownerBill[_client].amount = _amount;
            ownerBill[_client].ownerSupply = _supplyerAddress;
            emit billRegister(_id, _amount, _client);
	    jcltoken = JCLToken(_client);	    
    }

    function billPaying(uint _billId, uint _amount, address _client) external onlyOwner {
        	require(payingBill(_amount));
        	delete ownerBill[_client];
    }

    function payingBill(uint _amountToken) payable returns(bool){
        if(msg.value <= ownerBill[msg.sender].amount) return false;
        uint tokToEth = jcltoken.getBalanceInEth(_amountToken, convRate);
        uint quant = msg.value + tokToEth;
        return(jcltoken.sendCoin(ownerBill[msg.sender].ownerSupply, quant));
    }

    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }

}
