pragma solidity 0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";

contract JCLMain is Ownable {
    /////// VARIABLES DE ESTADO ////
    using SafeMath for uint256;

    ////// EVENTOS ///////////

    event billRegister (string billId, uint billAmount, address billRequest);

    ////// ESTRUCTURAS ///////

    struct Bill {
        string id;
        uint amount;
    }

    Bill[] public bills;

    ////// MAPPINGS ///////

    mapping (string => address) ownerBill;

    ////// MODIFICADORES /////

    modifier onlyBillRequested(string _billId) {
        require(msg.sender == ownerBill[_billId]);
        _;
    }

    ////// FUNCIONES //////

    function billRegistry(string _id, uint _amount) external onlyOwner {
        bills.push(_id, _amount);
        ownerBill[_id] = msg.sender;
        emit billRegister(_id, _amount, ownerBill[_id]);
    }

    function billPay(string _billId, uint _amount) external onlyBillRequested(_billId){
        // Incluir pago
    }

    function convertion(uint amount) internal {
        //
    }

}
