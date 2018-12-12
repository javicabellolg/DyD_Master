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

/** @title Create Bills. */

contract JCLTokenInterface{
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
}

contract createBills is Ownable{

    /** @dev Contrato patrón gestionado por un Factory Contract (JCLFactory). Define las funciones necesarias para efectuar el pago y finalizar los requerimientos de cobro.
      * @param _client definido en el constructor del contrato, se usa para mapear los parámetros relacionados con el pago de las facturas (id factura, cantidad a pagar yquien requiere el cobro).
      * @param _supplyerAddress definido en el constructor del contrato, se usa para definir el Owner del contrato, de modo que se evite posible vulnerabilidad asignando como Owner al cliente y que este pueda finalizar el contrato sin pagar la factura.
      * @param _id definido en el constructor del contrato, inicializa el id que el proveedor asigna a la factura pendiente de cobrar.
      * @param _amount definido en el constructor del contrato, indica la cantidad que se requiere cobrar.
      */

    using SafeMath for uint;
    uint16 convRate = 1;
    uint value;

    JCLTokenInterface public jcltoken;

    // Definicion de Eventos

    event billRegister (uint billId, uint billAmount, address billRequest);
    event billStatus (uint amount);

    // Definicion de Estructuras

    struct Bill {
        uint id;
        uint amount;
        address ownerSupply;
    }

    Bill[] public bills;

    mapping (address => Bill) public ownerBill; // Mapping para acceso externo a consulta de estado del requerimiento de cobro.

    constructor(address _client, address _supplyerAddress, uint _id, uint _amount) public {
            owner = _supplyerAddress;
	    ownerBill[_client].id = _id;
            ownerBill[_client].amount = _amount;
	    ownerBill[_client].ownerSupply = _supplyerAddress;
            emit billRegister(_id, _amount, _client);
    }

    modifier paying(address _client, uint _amount) {
        require(jcltoken.balanceOf(_client) >= _amount);
	jcltoken.transfer(ownerBill[_client].ownerSupply, _amount);
	ownerBill[_client].amount = ownerBill[_client].amount.sub(_amount);
        emit billStatus(ownerBill[_client].amount);
        _;
    }    

    function payingWithToken(address _client, uint _amount) external payable paying(_client, _amount) returns (uint) {
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
        jcltoken = JCLTokenInterface(_address);
    }
    
    function bye_bye() external onlyOwner {
        selfdestruct(msg.sender);
    }

    function () public payable{
        revert();
    }

}
