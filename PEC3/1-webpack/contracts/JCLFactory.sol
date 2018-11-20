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

contract JCLFactory {
    mapping(uint => address) public idToOwner;

    function createBillContract(uint _id, address _client, uint _amount) public {
	if (idToOwner[_id] == 0) {
            idToOwner[_id] = new createBills(_client, msg.sender, _id, _amount);  // Hay que tener en cuenta que realmente el mapping relaciona el id con el address del contrato que se genera. ¿quién es el owner, el cliente o el msg.sender?
        }
    }

    function getAmount(address account) public constant returns (uint) {
        //if (idToOwner[account] != 0) {
        //    return (createBills(counters[account]).getAmount());
        //}
    }
}
