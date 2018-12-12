// Import the page's CSS. Webpack will know what to do with it.
import '../styles/app.css'

// Import libraries we need.
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import JCLTokenArtifact from '../../build/contracts/JCLToken.json'
import FactoryArtifact from '../../build/contracts/JCLFactory.json' 
import CreateArtifact from '../../build/contracts/createBills.json'

// MetaCoin is our usable abstraction, which we'll use through the code below.
const JCLCoin = contract(JCLTokenArtifact)
const Factory = contract(FactoryArtifact)
const Create = contract(CreateArtifact)

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
let accounts
let account
let receiverCoin
let CreateAdd

const App = {
  start: function () {
    const self = this

    // Bootstrap the MetaCoin abstraction for Use.
    JCLCoin.setProvider(web3.currentProvider) 
    Factory.setProvider(web3.currentProvider)
    Create.setProvider(web3.currentProvider)
    alert("翨ienvenido! Comenzaremos guiando en el uso de la aplicaci贸n")
    alert("Comencemos...Aunque la interfaz sea poco amigable, ver胹 dos partes bien diferenciadas. La parte del proveedor y la parte del cliente. Para comenzar es necesario que revises si tienes activa en MetaMask la misma cuenta con la que has depslegado los contratos, esta es la cuenta Owner del Factory Contract que crea las facturas.")
    alert("Ahora, por favor, introduce un valor de factura (en Wei), dale un id num茅rco a la misma y cargala a una cuenta")
    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function (err, accs) {
      if (err != null) {
        alert('There was an error fetching your accounts.')
        return
      }

      if (accs.length === 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.")
        return
      }

      accounts = accs
      account = accounts[0]
      var address = document.getElementById("account");
      address.innerHTML = account;
      self.refreshBalance()
    })
  },

  setStatus: function (message) {
    const status = document.getElementById('status')
    status.innerHTML = message
  },

  setStatusClient: function (message) {
    const statusClient = document.getElementById('statusClient')
    statusClient.innerHTML = message
  },

  refreshBalance: function () {
   setInterval(function() {

    const self = this

    let meta
    let meta2

    var account = web3.eth.accounts[0]

    var accountInterval = setInterval(function () {
	if (web3.eth.accounts[0] !== account) {
            account = web3.eth.accounts[0];
            var address = document.getElementById("account");
            address.innerHTML = account;
            self.start();
            self.setStatus();
        }
    }, 500)

    JCLCoin.deployed().then(function (instance) {
      meta = instance
	return meta.balanceOf(account, { from: account })
    }).then(function (value) {
      const balanceElement = document.getElementById('balance')
      balanceElement.innerHTML = value.valueOf()
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error getting balance; see log.')
    })
    
    JCLCoin.deployed().then(function (instance) {
	meta2 = instance
        return meta2.balanceOf(account, { from: account })
    }).then(function (value) {
      const balanceClient = document.getElementById('balanceClientToken')
      balanceClient.innerHTML = value.valueOf()
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error getting balance; see log.')
    })
   }, 500)
  },

  registerBill: function () {
    const self = this

    JCLCoin.setProvider(web3.currentProvider)
    JCLCoin.web3.eth.defaultAccount=web3.eth.accounts[0]    
    Factory.setProvider(web3.currentProvider)
    Factory.web3.eth.defaultAccount=web3.eth.accounts[0]
    Create.setProvider(web3.currentProvider)
    Create.web3.eth.defaultAccount=web3.eth.accounts[0]

    const amount = parseInt(document.getElementById('amount_fact').value)
    const id = parseInt(document.getElementById('id_fact').value)
    const receiver = document.getElementById('debtor').value

    console.log(receiver)
    console.log(typeof(receiver))

    this.setStatus('Initiating transaction... (please wait)')

    let meta
    let fact
    receiverCoin = account
	

    Factory.deployed().then(function (instance) {
        fact = instance
        console.log(fact)
        fact.createBillContract(id, receiver, amount).catch(function (err) {
            console.log(err);
	    alert ("Usted no puede realizar esta acci贸n.No es el Owner del contrato por lo que no puede dar de alta requerimientos de pago. Por favor, rechace la transaccion y pague, moroso.")
        })
    }).catch(function (e) {
        console.log(e)
    })

  },

  payBill: function () {
    const self = this

    JCLCoin.setProvider(web3.currentProvider)
    JCLCoin.web3.eth.defaultAccount=web3.eth.accounts[0]
    Factory.setProvider(web3.currentProvider)
    Factory.web3.eth.defaultAccount=web3.eth.accounts[0]
    Create.setProvider(web3.currentProvider)
    Create.web3.eth.defaultAccount=web3.eth.accounts[0]

    const amountPago = parseInt(document.getElementById('amount_pago').value)
    const idPago = parseInt(document.getElementById('id_pago').value)
    const amountETH = document.getElementById('amount_pagoETH').value


    this.setStatus('Initiating transaction... (please wait)')

    let create
    let factory 
    let token
    let balance

    JCLCoin.deployed().then(function (instance) {
        return instance.balanceOf(account, { from: account })
    }).then(function (value) {
    	balance = value
    })

    Factory.deployed().then(function (instance) {
    	factory = instance
    	console.log(instance)
        console.log(factory.idToOwner(idPago))
        factory.idToOwner(idPago).then(function (address) {
		create = address
		CreateAdd = address
		var amountWei = web3.fromWei(amountETH, "ether")
		console.log(amountETH)
		if (amountETH >= 0 && balance >= amountPago) {
		  JCLCoin.deployed().then(function (instance) {
                	token = instance
                	console.log("La direcci髇 de control es: "+CreateAdd)
                	token.transfer(CreateAdd, amountPago).catch(function (e) {
                                console.log(e)
                                self.setStatusClient('Error al procesar la transacci贸n.Probablemente se deba a falta de fondos, por favor, revise sus fondos en su Wallet y revise el log.')
                  }).then(function(){
                  Create.at(create).payingWithToken(account, amountPago, {from: account, value: amountETH}).then(function(){
                        Create.at(create).ownerBill(account).then(function(data){
                                let dataCoin = data
                                let pendiente = dataCoin[1].toString()
                                self.setStatusClient("Transaccion realizada correctamente.Queda pendiente por pagar "+pendiente+" Weis de la factura con ID: "+idPago)
                                alert("Transaccion realizada correctamente.Queda pendiente por pagar "+pendiente+" Weis de la factura con ID: "+idPago)
                        })
                  }).catch(function (e) {
                                console.log(e)
                                self.setStatusClient('Error al procesar la transacci贸n.Probablemente se deba a falta de fondos, por favor, revise sus fondos en su Wallet y revise el log.')
                  })
                  })
        	  }).then(function () {
                	self.refreshBalance()
        	  })
		} else {alert("No tienes suficientes fondos")}
	})
    })    
  },

  getdir: function () {
    const self = this

    JCLCoin.setProvider(web3.currentProvider)
    JCLCoin.web3.eth.defaultAccount=web3.eth.accounts[0]
    Factory.setProvider(web3.currentProvider)
    Factory.web3.eth.defaultAccount=web3.eth.accounts[0]
    Create.setProvider(web3.currentProvider)
    Create.web3.eth.defaultAccount=web3.eth.accounts[0]

    const addressToken = document.getElementById('JCLadd').value
    const idPago = parseInt(document.getElementById('id_pago2').value)

    console.log("La direccion de JCLToken es: "+addressToken)

    this.setStatus('Actualizando direcci髇... (please wait)')

    let create
    let factory

    Factory.deployed().then(function (instance) {
      factory = instance
      factory.idToOwner(idPago).then(function (address) {
      	create = address
	console.log(address)
	console.log(typeof(addressToken))
	Create.at(create).setJCLTokenContractAddress(addressToken)
	})
    })
  }

}

window.App = App

window.addEventListener('load', function () {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn(
      'Using web3 detected from external source.' +
      ' If you find that your accounts don\'t appear or you have 0 MetaCoin,' +
      ' ensure you\'ve configured that source properly.' +
      ' If using MetaMask, see the following link.' +
      ' Feel free to delete this warning. :)' +
      ' http://truffleframework.com/tutorials/truffle-and-metamask'
    )
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider)
  } else {
    console.warn(
      'No web3 detected. Falling back to http://127.0.0.1:9545.' +
      ' You should remove this fallback when you deploy live, as it\'s inherently insecure.' +
      ' Consider switching to Metamask for development.' +
      ' More info here: http://truffleframework.com/tutorials/truffle-and-metamask'
    )
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:9545'))
  }

  App.start()
})
