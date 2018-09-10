# Master Ethereum, Tecnología Blockchain y Criptoeconomía
## Diseño y Desarrollo - 
## Modulo 1: Fundamentos y Herramientas
Para todo el proceso se considera ya inicializada la blockchain con Ganache y desplegado el SmartContract según el tutorial visto en clase.
- #### Comprobar que exite conexión a un nodo
> Para realizar dicha comprobación se interactuará con la blockchain haciendo uso de web3:
> ```
> $ truffle(development)> web3.version.node
> 'EthereumJS TestRPC/v2.2.1/ethereum-js'
> ```
- #### Comprobar si esta o no sincronizando nuevos bloques. ¿Por qué?
> Ganache-cli no sincroniza o mina nuevos bloques de forma automática. Sin embargo,
> si que mina nuevos bloques en cuanto exista nuevas transacciones, hasta entonces
> se mantendrá en un estado de stand-by
- #### Balance de la cuenta numero 3 de Ganache o ganache-cli
> El balance de la tercera cuenta se mantendrá íntegro, pues no ha sido utilizada para
> el depsliegue del SmartContract:
> ````
> $ truffle(development)> web3.fromWei(web3.eth.getBalance("0x48e5a8fd78fd8ec4c2bbc7f4935f5ff40c3501e7").toString(10))
> '100'
> ```
- #### Número de bloque en el que se encuentra la blockchain en ese instante. ¿Por qué?
> El número del bloque es pequeño, por lo que se ha comentado anteriormente, la blockchain
> se mantiene en stand-by a la espera de la existencia de nuevas transacciones:
> ```
> truffle(development)> web3.eth.blockNumber
> 4
> ```
> La existencia de 4 bloques es porque en el momento de la creción se crea el bloque origen y
> las transferencias para el despliegue del SmartContract.
- #### Direccóion del host de la blockchain.
> ```
> truffle(development)> web3.currentProvider
> HttpProvider {
> host: 'http://127.0.0.1:8545',
> timeout: 0,
> user: undefined,
> password: undefined,
> headers: undefined,
> send: [Function],
> sendAsync: [Function],
> _alreadyWrapped: true }
> ```
- #### Acceda a [Ethgasstation](https://ethgasstation.info) y convierta el precio del gas en ese instante a Ether
> En el momento de realizar el ejercicio, el gas está a 3.5 Gwei. Esto es un total de 3500000000 wei
![Capture](images/gas.png)
