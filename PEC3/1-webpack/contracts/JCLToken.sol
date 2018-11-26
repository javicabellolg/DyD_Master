////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Nombre: JCLToken.sol
//		Autor: Javier Cabello Laguna
//		Version: 0.2
//		Descripción:
//			Creación del Token y del initial_supply Requiere: $nom install openzeppelin-solidity			
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity 0.4.24;  //Se fija la versión que es lo que se ha probado

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";  //Se ha instalado previamente con $ npm install openzeppelin-solidity

contract JCLToken is ERC20 {

    string public name = "JCLToken";
    string public symbol = "JCL";
    uint8 public decimals = 2;
    uint public INITIAL_SUPPLY = 1000000000000000000;

    mapping (address => uint) public balances;

    constructor() public {
        _mint(msg.sender, INITIAL_SUPPLY); //Esta función está definida en ERC20.sol para la asignación de tokens a una dirección.
    }
  
}
