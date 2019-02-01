////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Nombre: CustToken.sol
//		Autor: Javier Cabello Laguna
//		Version: 0.1
//		Descripción:
//			Creación del Token y del initial_supply Requiere: $npm install openzeppelin-solidity@2.0 --save-exac			
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
pragma solidity 0.4.24;  

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol"; 

contract CustToken is ERC20 {

    string public name = "CustToken";
    string public symbol = "CTKN";
    uint8 public decimals = 8;
    uint public INITIAL_SUPPLY = 1000000000000000000;

    mapping (address => uint) public balances;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY); 
    }
  
}