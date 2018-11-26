////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Nombre: CreaateBills.sol
//		Autor: Javier Cabello Laguna
//		Version: 0.2
//		Descripción:
//			Contratos creados para gestión de pagos de requerimientos de cobro.		
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
pragma solidity 0.4.24;

import "./Ownable.sol";
import "./JCLToken.sol";

contract createBills is Ownable{

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
    mapping (address => uint) private balances;

    constructor(address _client, address _supplyerAddress, uint _id, uint _amount) public {
            owner = _client;
            ownerBill[_client].id = _id;
            ownerBill[_client].amount = _amount;
	    ownerBill[_client].ownerSupply = _supplyerAddress;
            emit billRegister(_id, _amount, _client);
	    jcltoken = JCLToken(_client);	    
    }

    function payingOnlyETH() external payable {
        require(msg.value >= ownerBill[msg.sender].amount);  //La llamada sería createBills.at("").payingOnlyETH.send({from: userAccount, value: web3.utils.toWei("cantidad", "ether")})
	address(ownerBill[msg.sender].ownerSupply).transfer(msg.value);
        delete ownerBill[msg.sender]; //El traspaso ya se ha hecho en la llamada.
    }

    function payingWithToken(address _client, uint _amount) external payable {
    	//require(_amount >= ownerBill[_client].amount);
	//require(jcltoken.balanceOf(msg.sender) >= msg.value);
	ownerBill[_client].amount -= _amount;    // Este amount va a ser la cantidad en ethers
	address(ownerBill[msg.sender].ownerSupply).transfer(msg.value);
	delete ownerBill[msg.sender];
    }

    //function withdrawBill(uint _withdrawAmount) public {
    //    ownerBill[msg.sender].amount -= _withdrawAmount;
    //    owner.transfer(_withdrawAmount);
    //}

    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }

}
