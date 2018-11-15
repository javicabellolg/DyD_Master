pragma solidity 0.4.24;

import "./Ownable.sol";
import "./JCLToken.sol";

contract JCLMain is Ownable {
    uint16 convRate = 1;
    JCLToken public jcltoken;

    event billRegister (uint billId, uint billAmount, address billRequest);


    struct Bill {
        uint id;
        uint amount;
        address ownerSupply;
    }

    Bill[] public bills;


    mapping (address => Bill) ownerBill;   // Se crea un mapping que cree un par clave - valor de address y la Struct que tenemos creada. 
                                            // Así será este únicamente el que almacene las facturas activas y será mas fácil eliminarlas.

    modifier onlyExactlyAmount(uint _amount, address _client) {
        require(_amount == ownerBill[_client].amount);
        _;
    }

    modifier onlyBillRequested(uint _id, address _client) {
        require(_id == ownerBill[_client].id);
        _;
    }

    constructor(address _addressJclToken) public {
        owner == msg.sender;
	jcltoken = JCLToken(_addressJclToken);
    }

    function billRegistry(uint _id, uint _amount, address _client) external onlyOwner {
        ownerBill[_client].id = _id;
        ownerBill[_client].amount = _amount;
        ownerBill[_client].ownerSupply = msg.sender;
        //bills.push(_id, _amount);
        //ownerBill[_id] = _client;
        emit billRegister(_id, _amount, _client);
    }

    function billPay(uint _billId, uint _amount, address _client) external onlyBillRequested(_billId, _client) onlyExactlyAmount(_amount, _client) {
        require(payBill(_amount));
        delete ownerBill[_client];
    }

    function payBill(uint _amountToken) payable returns(bool){
        if(msg.value <= ownerBill[msg.sender].amount) return false;
        uint tokToEth = jcltoken.getBalanceInEth(_amountToken, convRate);
        uint quant = msg.value + tokToEth;
        return(jcltoken.sendCoin(ownerBill[msg.sender].ownerSupply, quant));
    }
}
