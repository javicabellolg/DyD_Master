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
import "./CustToken.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract CustTokenInterface{
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 value) public view returns (bool);
}

contract createPays is Ownable{

    using SafeMath for uint;
    uint16 convRate = 1;
    uint value;
    uint penalizedValue;

    CustTokenInterface public custoken;

    // Definicion de Eventos

    event billRegister (uint billId, uint billAmount, address billRequest);
    event billStatus (uint amount);

    // Definicion de Estructuras

    struct Bill {
        uint id;
        uint amount;
        address ownerSupply;
        uint createdBill;
        uint expiresBill;
        bool penalized;
    }

    Bill[] public bills;

    mapping (address => Bill) public ownerBill;

    constructor(address _client, address _supplyerAddress, uint _id, uint _amount, uint _created, uint _expires) public {
        owner = _supplyerAddress;
        ownerBill[_client].id = _id;
        ownerBill[_client].amount = _amount;
        ownerBill[_client].ownerSupply = _supplyerAddress;
        ownerBill[_client].createdBill = _created;
        ownerBill[_client].expiresBill = _expires;
        ownerBill[_client].penalized = false;
        emit billRegister(_id, _amount, _client);
    }

    modifier evaluateExpires(address _client){
        //uint _amountPenalized;
        if (now >= ownerBill[_client].expiresBill){
            ownerBill[_client].penalized = true;
            if (now < ownerBill[_client].expiresBill + 1 minutes){ penalizedValue = 10; } else { penalizedValue = 50; }
            //else if (now >= ownerBill[_client].expiresBill + 1 minutes){
            //    if (now < ownerBill[_client].expiresBill + 7 minutes) { penalizedValue = 20; }
            //    else if (now >= ownerBill[_client].expiresBill + 7 minutes){
            //        if (now < ownerBill[_client].expiresBill + 30 minutes) { penalizedValue = 30; }
            //        else if (now >= ownerBill[_client].expiresBill + 30 minutes){
            //            if (now < ownerBill[_client].expiresBill + 90 minutes) { penalizedValue = 100; }
            //            else if (now >= ownerBill[_client].expiresBill + 90 minutes){
            //                if (now < ownerBill[_client].expiresBill + 180 minutes) { penalizedValue = 200; }
            //                else if (now >= ownerBill[_client].expiresBill + 180 minutes){
            //                    penalizedValue = 2000;// Se inscribe en la blacklist
            //            }
            //        }
            //    }
            //}
            //if (now >= ownerBill[_client].expiresBill + 1 hours){
            //    _amountPenalized = ownerBill[_client].amount / 100;
            //ownerBill[_client].amount += 10;
            //} else {
            //    _amountPenalized = ownerBill[_client].amount / 200;
            //    ownerBill[_client].amount += _amountPenalized;
           //}
        }
        else { penalizedValue = 0; }
        _;
    }

    modifier paying(address _client, uint _amount) {
        require(custoken.balanceOf(_client) >= _amount);
        custoken.transfer(ownerBill[_client].ownerSupply, _amount);
        ownerBill[_client].amount = ownerBill[_client].amount.sub(_amount);
        emit billStatus(ownerBill[_client].amount);
        _;
    }    

    function payingWithToken(address _client, uint _amount) external payable evaluateExpires (_client) paying (_client, _amount) returns (uint) {
        ownerBill[_client].amount = ownerBill[_client].amount.add(penalizedValue);
        ownerBill[_client].amount = ownerBill[_client].amount.sub(_amount);
        emit billStatus(ownerBill[_client].amount);
        address(ownerBill[msg.sender].ownerSupply).transfer(msg.value);
        value = msg.value;
        ownerBill[_client].amount = ownerBill[_client].amount.sub(value);
        if (ownerBill[_client].amount == 0) {
            delete ownerBill[msg.sender];
	}
        emit billStatus(ownerBill[_client].amount);
        return (ownerBill[_client].amount);
    }

    function supplyerAddress(address _client) public returns (address){
        return (ownerBill[_client].ownerSupply);
    }

    function setJCLTokenContractAddress(address _address) external {
        custoken = CustTokenInterface(_address);
    }
    
    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }		

    function () public payable{
        revert();
    }

}