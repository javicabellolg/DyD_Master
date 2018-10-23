# Master Ethereum, Tecnología Blockchain y Criptoeconomía
## Diseño y Desarrollo - 
## PEC2
### Ejercicio 1 - ENS

> Para la realización de este ejercicio, se ha tomado como referencia la siguiente documentación:
> [ENS - Oficial](http://docs.ens.domains/en/latest/quickstart.html)
> [ENS - User Guide](https://github.com/ensdomains/ens/blob/master/docs/userguide.rst)

En primer lugar, es necesario tener sincronizado un nodo completo:
```
$ geth --rinkeby --syncmode "fast" --rpc --rpcapi db,eth,net,web3,personal,shh --cache=1024 --shh --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" console
```
Si no se realiza la sincronización completa del nodo, es probable que aparezca el siguiente error al intentar registrar el dominio:

```
$ new Date(testRegistrar.expiryTimes(web3.sha3('pruebaJcL_prueba')).toNumber() * 1000)
> Error: invalid address
>    at web3.js:3930:15
>    at web3.js:3734:22
>    at web3.js:5025:28
>    at map (<native code>)
>    at web3.js:5024:12
>    at web3.js:5050:18
>    at web3.js:5075:23
>    at web3.js:4102:22
>    at apply (<native code>)
>    at web3.js:4227:12
```

> ##### Conexión a la consola geth
>
> Con el comando anterior corriendo, se puede conectar a la consola de geth de la ejecución del siguiente modo:
> ```
> geth --datadir=$HOME/.rinkeby attach ipc:/home/javi/.ethereum/rinkeby/geth.ipc console
> ```

Una vez que se tiene sincronizado el nodo, se puede proceder al registro del dominio. 

##### Registrando el dominio

Para esta parte, es necesario descargar un plugin para geth, con el fin de poder utilizar los comandos necesarios para el registro del dominio. El plugin se puede descargar del siguiente [link](https://github.com/ensdomains/ens/blob/master/ensutils-testnet.js).
> Es muy importante remarcar que esta descarga únicamente sirve para realización de pruebas y no es aconsejable
> incluirla en una versión productiva. __Ver cabecera de documento enlazado__

Con este plugin descargado se puede proceder a su carga para poder utilizar los comandos específicos:

```
$ loadScript ('/path/to/ens-utils-testnet.js')
```
Esto, por defecto, cargará el script que conectará por defecto con Ropsten, para conectar con Rinkeby, deberemos cambiar las siguientes líneas:
```
contract address: 0xe7410170f87102df0055eb195163a03b7f2bff4a (line 220)
publicResolver address: 0x5d20cf83cb385e06d2f2a892f9322cd4933eacdc (line 1314)
```

Ahora se tendría todo listo para proceder al registro del dominio. Se procede a indicar los pasos:

1. Desbloquear cuenta para realización de transacciones:
```
$ personal.unlockAccount(eth.accounts[2])
Unlock account 0xef1c...
Passphrase:
```
> En  mi caso he utilizado la cuenta número 2 de mi wallet. Pedirá la Passphrase de la cuenta, por lo que es
> conveniente tenerla a mano.
> Si se quiere setear la cuenta en el coinbase, es una buena práctica hacer lo siguiente
> ```
> $ miner.setEtherbase(eth.accounts[2])
> true
> $ eth.coinbase
> "0xef1c..."
> ```

2. Se comprobará a continuación si el dominio está libre:
```
$ new Date(testRegistrar.expiryTimes(web3.sha3('nombre_dominio')).toNumber() * 1000)
```
En el caso que ocupa, se ha procedido a comprobar si existe registrado el dominio __dyd_JCL__:
```
$ new Date(testRegistrar.expiryTimes(web3.sha3('dyd_JCL')).toNumber() * 1000)
<Date Thu, 01 Jan 1970 01:00:00 CET>
```
Como se observa la fecha de registro es anterior (muy anterior) a la fecha actual, lo que significa que el dominio está libre, por lo que se puede proceder a su registro en el __registrar__ .test:
```
$ testRegistrar.register(web3.sha3('dyd_JCL'), eth.accounts[2], {from: eth.accounts[2]})
"0x7329d6540a43146845a15724dc76b8ee1113b917ff7b2ed5928021cf2215038c"
```
Con esto, se registra la compra y quien es el owner. Como se puede observar devuelve una dirección que es correspondiente a la transacción, la cual puede verse en el siguiente [enlace](https://rinkeby.etherscan.io/tx/0x7329d6540a43146845a15724dc76b8ee1113b917ff7b2ed5928021cf2215038c).

3. A continuación, se le indica al registro de ENS cual es la dirección pública del dominio.
```
$ ens.setResolver(namehash('dyd_JCL.test'), publicResolver.address, {from: eth.accounts[2]});
"0x6cfa7eee37286c2bec049a018f321d8956b3e1c7d10856f8700fc67fb73ddfa9"
```
Al igual que el anterior, devuelve un id de transacción que puede ser visto en el siguiente [enlace](https://rinkeby.etherscan.io/tx/0x6cfa7eee37286c2bec049a018f321d8956b3e1c7d10856f8700fc67fb73ddfa9).

Básicamente, lo que se ha hecho es decir al registro de ENS de la red de pruebas que el dominio 'dyd_JCL.test' corresponde con el acceso a la dirección devuelta por $publicResolver.address:
```
$ publicResolver.address
"0x5d20cf83cb385e06d2f2a892f9322cd4933eacdc"
```
4. Ahora hay que esperar a que la transacción sea minada, para ello, en el enlace indicado anteriormente se puede comprobar. Una vez minada la transacción, le indicaremos al Resolver quien es el propietario del dominio, uniendo éste con la dirección de nuestra cuenta:
```
$ publicResolver.setAddr(namehash('dyd_JCL.test'), eth.accounts[2], {from: eth.accounts[2]});
"0xe2433a69a06eab352aee15f06b0375289ef932c9d4a0920cc27f85999762ba55"
```
Igualmente, devuelve un id de transacción que puede seguirse en etherscan.io. Una vez hecho esto, es fácil comprobar quien es el propietario del dominio. Se ponen varias evidencias:
```
$ getAddr('dyd_JCL.test')
"0xef1c2fda40129d7cd7e5218162f60122c68ca047"
$ eth.accounts[2]
"0xef1c2fda40129d7cd7e5218162f60122c68ca047"
$ ens.owner(namehash('dyd_JCL.test'))
"0xef1c2fda40129d7cd7e5218162f60122c68ca047"
```