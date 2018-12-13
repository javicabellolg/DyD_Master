////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Nombre: JCLFactory.sol
//		Autor: Javier Cabello Laguna
//		Version: 0.2
//		Descripción:
//			Factory Contract para la creación de nuevos requerimientos de cobro. Se creará un contrato por cada ticket requerido por el proveedor.		
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity 0.4.24;

import "./CreateBills.sol";
import "./Ownable.sol";

contract JCLFactory is Ownable{
    mapping(uint => address) public idToOwner;

    function createBillContract(uint _id, address _client, uint _amount) public onlyOwner {
	if (idToOwner[_id] == 0) {
            idToOwner[_id] = new createBills(_client, msg.sender, _id, _amount);  // Hay que tener en cuenta que realmente el mapping relaciona el id con el address del contrato que se genera. El Owner del contrato es el msg.sender, siendo este únicamente el proveedor.
        }
    }

    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }
}
