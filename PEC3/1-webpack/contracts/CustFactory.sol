////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//		Nombre: CustFactory.sol
//		Autor: Javier Cabello Laguna
//		Version: 0.1
//		Descripción:
//			Factory Contract para la creación de nuevos requerimientos de cobro. Se creará un requerimiento de cobro por cada compra. Estos requerimientos de cobro pueden ser
//          satisfechos en el momento o aplazados.		
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity 0.4.24;

import "./CreatePays.sol";
import "./Ownable.sol";

contract CustFactory is Ownable{
    mapping(uint => address) public idToOwner;

    function createPayContract(uint _id, address _client, uint _amount) public onlyOwner {
        uint created;
        uint expires;
        if (idToOwner[_id] == 0) {
            created = now;
            expires = created + 1 minutes;
            idToOwner[_id] = new createPays(_client, msg.sender, _id, _amount, created, expires);  // Hay que tener en cuenta que realmente el mapping relaciona el id con el address del contrato que se genera. El Owner del contrato es el msg.sender, siendo este únicamente el proveedor.
        }
    }

    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }
}