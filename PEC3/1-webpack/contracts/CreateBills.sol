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
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract createBills is Ownable{

    using SafeMath for uint;
    uint16 convRate = 1;
    uint value;
    JCLToken public jcltoken;

    event billRegister (uint billId, uint billAmount, address billRequest);
    event billStatus (uint amount);

    struct Bill {
        uint id;
        uint amount;
        address ownerSupply;
    }

    Bill[] public bills;

    mapping (address => Bill) public ownerBill;
    mapping (address => uint) private balances;

    constructor(address _client, address _supplyerAddress, uint _id, uint _amount) public {
            //owner = _client;
            owner = _supplyerAddress;
	    ownerBill[_client].id = _id;
            ownerBill[_client].amount = _amount;
	    ownerBill[_client].ownerSupply = _supplyerAddress;
            emit billRegister(_id, _amount, _client);
	    jcltoken = JCLToken(_client);	    
    }

    modifier paying(address _client, uint _amount) {
	ownerBill[_client].amount = ownerBill[_client].amount.sub(_amount);
        emit billStatus(ownerBill[_client].amount);
        _;
    }    

    function payingWithToken(address _client, uint _amount) external payable paying(_client, _amount) returns (uint) {
	address(ownerBill[msg.sender].ownerSupply).transfer(msg.value);
	value = msg.value.div(10**18);
	ownerBill[_client].amount = ownerBill[_client].amount.sub(value);
        if (ownerBill[_client].amount == 0) {
		delete ownerBill[msg.sender];
	}
	return (ownerBill[_client].amount);
    }

    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }

    function () public payable{
        revert();
    }

}
