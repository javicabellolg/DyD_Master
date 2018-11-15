pragma solidity 0.4.24;  //Se fija la versión que es lo que se ha probado

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";  //Se ha instalado previamente con $ npm install openzeppelin-solidity
import "./ConvertLib.sol";

contract JCLToken is ERC20 {

    string public name = "JCLToken";
    string public symbol = "JCL";
    uint8 public decimals = 8;
    uint public INITIAL_SUPPLY = 100000000;

    mapping (address => uint) balances;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY); //Esta función está definida en ERC20.sol para la asignación de tokens a una dirección.
    }
  
    function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
         if (balances[msg.sender] < amount) return false;
         balances[msg.sender] -= amount;
         balances[receiver] += amount;
         emit Transfer(msg.sender, receiver, amount);
         return true;
    }

    function getBalanceInEth(uint _amount, uint16 _conv) public view returns(uint){
         return ConvertLib.convert(_amount, _conv);
    }

    function getBalance(address addr) public view returns(uint) {
         return balances[addr];
    }

}
