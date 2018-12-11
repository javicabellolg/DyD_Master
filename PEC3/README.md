# Master Ethereum, Tecnología Blockchain y Criptoeconomía
## Diseño y Desarrollo - 
## PEC 3: Trabajo Final - Sistema de pago a proveedores con registros de Facturas

> Para la realización del siguiente proyecto se ha tomado como referencia el proyecto truffle webpack, por lo que la parte del Front End puede tener ciertas similitudes 
> estéticas. Se ha creado un token propio (JCLToken) con un supply y decimales diferentes, estableciendo por defecto el tipo de cambio en 1 JCLToken = 1 Wei. No es alcance 
> de este trabajo la realización de la tasa de conversión. El desarrollo de SmartContracts, Conexión vía Web3, Testing y Funcionalidad es completamente original.

## Objetivo y alcance del trabajo

Se va a realizar una aplicación que permita el registro de facturas pendientes de pago. La funcionalidad será básica, el usuario que requiere el pago (en adelante proveedor) registra una factura en la Blockchain. En este registro se indica el id de la factura, usuario a quien se requiere el cobro (en adelante cliente) y la cantida que se adeuda.

Una vez registrada la factura, el cliente puede efectuar el pago al proveedor haciendo uso de los tokens, los ethers o de ambos. Por defecto, se ha establecido que todas las unidades sean equivalente a Weis. Por tanto, la cantidad que se indica adeudada estará indicada en Weis y la tasa de cambio del Token personalizado es 1 Token = 1 wei.

## Consideraciones previas

Para la correcta ejecución del programa es necesario tener instalado:
- npm version 5.6.0 o superior
- truffle version 4.1.14 o superior
- solidity version 0.4.24
- ganache o Ganache-cli
- librería OpenZeppelin: `$ npm install openzeppelin-solidity`

El resto de dependencias necesarias se encuentran en el fichero _package.json_ para que sean instaladas en la ejecución de `$ npm install`inicial

Con esto se puede proceder a descargar del [repositorio habilitado] (https://github.com/javicabellolg/DyD_Master/tree/dev/PEC3/1-webpack) los archivos para la ejecución de la dApp. Una vez descargado es necesario acceder a la raíz y ejecutar `npm install` para instalar todas las dependencias necesarias.

Una vez instaladas las dependencias es necesario compilar los contratos, pues se proporcionan sin compilar:
`$ truffle compile`
Antes de realizar la migración es necesario tener una red disponible donde desplegar los contratos. Para ello, se utilizará `ganache-cli`. Para evitar el bajo límite de gas que por defecto tiene ganache, se utilizará el flag `-l` que permite establecer el límite personalizado:
`$ ganache-cli -l 100000000`
>Como se observa se establece un límite suficientemente alto.
Por otro lado, al modificar el límite en la red también es necesario establecer un límite de gas para el proyecto, esto se hará en el fichero `truffle.js`. A continuación se muestra la configuración establecida para este proyecto:
```
module.exports = {
  networks: {
    ganache: {
      host: '127.0.0.1',
      port: 8545,
      gas:"29000000",
      network_id: '*' // Match any network id
    }
  }
}
```
Con esto, se puede proceder a migrar el proyecto a la red:
```
$ truffle migrate --network ganache
```
Aparecerán las direcciones de todos los contratos que se despliegan:
```
MacBook-Pro-de-Javier-Cabello:1-webpack JaviMac$ truffle migrate --network ganache
Using network 'ganache'.

Running migration: 1_initial_migration.js
  Deploying Migrations...
  ... 0x7c111554a8217418fcbe551c9a69140505c4c01adc43299ec6e7a40a6b54f0fe
  Migrations: 0x47fe9e0aa190c0f633b30750b8cc3e2137f82bb4
Saving successful migration to network...
  ... 0xfe8ec31f9391f8a665ff5101a88293dd756ad015aeb37a11cda755907c4699e9
Saving artifacts...
Running migration: 2_deploy_contracts.js
  Deploying JCLToken...
  ... 0xa0f8b522ff20ebb5a5c6b6bc17350ecd081746d06936a76793aa94f969c2cf72
  JCLToken: 0x766a7df1c19d89ea8cdb2c0b9f5af35cf8a525b7
  Deploying JCLFactory...
  ... 0xedd7602d0a1c82f9904b1064b7068ace20cf3d78399700cf47b6479879c3a13e
  JCLFactory: 0xe92e392ba106f7ee91956b77693c07186f80dc3a
  Deploying createBills...
  ... 0x5b8b891a7db582e6d29c8a126d356031ef4523600f91a4c7c5eed7d4cbd33835
  createBills: 0x7eafe5e4aadaaa2ed0567fea5a377bb52d71d0bd
Saving successful migration to network...
  ... 0x1c0bd29d881896c6f10906e3ec56ab0dbb0008e051c17693fb1fbbffebf0fb70
Saving artifacts...
Running migration: 3_mint_tokens.js
la red es la siguiente
ganache
Saving successful migration to network...
  ... 0xed9df7c260470d2c6442970a60d6fe4751709c03f0c3ee922357416a3df7c9db
Saving artifacts...
```
Como puede verse se despliegan varios contratos que, a continuación, se pasa a explicar su funcionalidad:
-**JCLToken.sol**: Contrato prefijado y tomado de una plantilla. Se especifica en el contrato que sea un token ERC20, heredando las propiedades de estos, con esto se evitan ciertas brechas de seguridad conocidas asociadas a las transferencias como el _reentrancy_. Se especifica un supply inicial y el símbolo del token (_JCL_). Simplemente proporciona un token, no siendo el objetivo de este trabajo funcionalidades asociadas.
-**JCLFactory.sol**: Este contrato es de creación propia. Es un _factory contract_ que se encarga de dar de alta a los requerimientos de pago. Como estos requerimientos únicamente se pueden dar de alta por los proveedores, se ha heredado propiedades de _Ownable.sol_. Se ha hecho el owner del contrato a la cuenta que lo despliega, considerando esta como el proveedor principal. Gracias a la herencia de _Ownable.sol_ y al modificador _OnlyOwner_ únicamente la cuenta 0 `account[0]`puede dar de alta las facturas.
> Se establece la cuenta `account[0]` por ser la que se tiene definida por defecto como coinbase. Para este trabajo se ha supuesto un único proveedor, en el futuro se ampliará esta funcionalidad.
-**CreateBills.sol**: Es el contrato que gestiona los requerimientos de cobro. Se mantendrá activo hasta que el cliente haya satisfecho el pago completo de la cantidad adeudada. Así mismo, tiene una parada de emergencia que únicamente puede activar el _owner_ del contrato (que es el proveedor `account[0]`). Se han tomado medidas de seguridad para evitar que únicamente la cuenta _owner_ del contrato sea capaz de eliminar de emergencia el contrato. Así mismo, se hace uso de la librería `SafeMath.sol` para evitar problemas de seguridad conocidos como `overflow` o `underflow`. Así mismo, se fija el destinatario en el contrato que por defecto es el _owner_ del mismo dado que es el que habilita el requerimiento de pago. De esta forma, se evita comportamientos maliciosos, desviando fondos a otras cuentas y reduciendo la cantidad adeudada, puesto que no tiene posibilidad de configurarlo en la llamada de la función. De este modo, la dApp cuando el cliente realiza un pago pasará a la función los siguientes parámetros:
```
function payingWithToken **(address _client, uint _amount)** external payable paying(_client, _amount) returns (uint) {
```
El parámetro correspondiente al `_to` está definido desde la creación del contrato en un struct. Se copia el constructor:
```
constructor(address _client, address _supplyerAddress, uint _id, uint _amount) public {
            owner = _supplyerAddress;
            ownerBill[_client].id = _id;
            ownerBill[_client].amount = _amount;
            ownerBill[_client].ownerSupply = _supplyerAddress;
            emit billRegister(_id, _amount, _client);
    }
```
Si se observa la llamada desde el contrato `JCLFactory.sol`:
```
idToOwner[_id] = new createBills(_client, msg.sender, _id, _amount);
```
El parámetro `_supplyerAddress` se pasa como el `msg.sender` de `JCLFactory.sol` que, como se ha comentado anteriormente, solo puede ejecutar el proveedor.

### Levantando el Front

Para habilitar el Front y poder acceder a la interfaz gráfica de la dApp, será necesario situarse en la raíz y ejecutar:

```
npm run dev
```

Aparecerá levantada en `http://localhost:8080`la aplicación.
