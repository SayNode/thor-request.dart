# thor-request.dart

This package enables you to talk to VeChain blockchain without hassle.
This package is mostly a one to one translation of thor-requests.py
https://github.com/laalaguer/thor-requests.py

- Covers most topic on contract interaction, vet transfer, vtho transfer and transaction debug.

- Automatically estimate gas and decode events/revert reasons for you.



# Quick Start
```dart
import 'package:thor_request_dart/connect.dart';

Connect connector = Connect("https://testnet.veblocks.net")

```

## API Reference

```dart
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/wallet.dart';
import 'package:thor_request_dart/contract.dart';

//Wallet
Wallet wallet = Wallet.fromPrivate(Uint8List privateKey);
Wallet wallet = Wallet.fromMnemonic(List<String> words);
Wallet wallet = Wallet.fromKeyStore(String keyStore, String password);
Wallet wallet = Wallet.newWallet(); // Create a new random wallet

// Contract
//must enter contract meta(solidity compiled contract)
Contract contract = Contract(String jsonString);
Contract contract = Contract.fromFile(String path);

//Connect
Connect connector = Connect(String node_url);
Connect connector.getChainTag();
Connect connector.getAccount(String address);
Connect connector.getBlock(String block, bool expanded);//default block is best
Connect connector.getTransaction(String tx_id);
Connect connector.getTransactionReceipt(String tx_id);
Connect connector.waitForTxReceipt(String tx_id);
Connect connector.replayTx(String tx_id);

//Ticker
connector.ticker(); //returns the newest block block s a Stream

//Deploy a smart contract
connector.deploy(Wallet wallet, Contract contract);

//Call a contract function (won't spend gas)
connector.call(String caller, Contract contract, String func_name,
      List funcParams, String to,
      {BigInt value,
      int gas = 0, // Note: value is in Wei
      String? gasPayer, // Note: gas payer of the tx
      String block = "best" // Target at which block
      });

//Execute a contract fucntion (spend real gas)
connector.transact(Wallet wallet, Contract contract, String func_name,
      List funcParams, String to,
      {BigInt? value, // Note: value is in Wei
      int expiration = 32,
      int gasPriceCoef = 0,
      int gas = 0,
      String? dependsOn, // ID of old Tx that this tx depends on, None or string
      bool force = false, // Force execute even if emulation failed
      Wallet? gasPayer // fee delegation feature
      );

// Multi clauses support (MTT)
clause1 = connector.clause(Contract contract, String func_name, List funcParams, String to, {BigInt? value}).getDevClause() 
clause2 = connector.clause(Contract contract, String func_name, List funcParams, String to, {BigInt? value}).getDevClause()

//.getDevClause returns a clause object as declared in the thor devkit

// Call them (won't spend gas)
//Clause has to be a Clause object from the thor devkit
connector.callMulti(String caller, List<Clause> clauses, {int gas = 0, String? gasPayer, String block = "best"})

// Or execute them
//Clause has to be a Clause object from the thor devkit
connector.transactMulti(Wallet wallet, List<Clause> clauses,
      {int gasPriceCoef = 0,
      int gas = 0,
      String? dependsOn,
      int expiration = 32,
      bool force = false,
      Wallet? gasPayer})
```

// Examples (Blockchain)
## Get Tx/Block/Account/Receipt
```dart
import 'package:thor_request_dart/connect.dart';

connector = Connect("https://testnet.veblocks.net")

// Account
connector.getAccount('0x7567d83b7b8d80addcb281a71d54fc7b3364ffed')

// >>> {'balance': '0x21671d16fd19254d67', 'energy': '0xf809f75231563b5f1d', 'hasCode': False}

// Block
connector.getBlock('0x0084f21562e046b1ae9aa70b6cd3b7bc2e8312f3961716ee3fcd58ce8bcb7392')

// >>> {'number': 8712725, 'id': '0x0084f21562e046b1ae9aa70b6cd3b7bc2e8312f3961716ee3fcd58ce8bcb7392', 'size': 243, 'parentID': '0x0084f214dd0b96059a142b5ac33668a3bb56245bde62d72a7874dc5a842c89e7', 'timestamp': 1617158500, 'gasLimit': 281323205, 'beneficiary': '0xb4094c25f86d628fdd571afc4077f0d0196afb48', 'gasUsed': 0, 'totalScore': 33966653, 'txsRoot': '0x45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0', 'txsFeatures': 1, 'stateRoot': '0xfe32d569f127a9a1d6f690bb83dae1c91fee31cac6596ae573ad3fa76c209670', 'receiptsRoot': '0x45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0', 'signer': '0x39218d415dc252a50823a3f5600226823ba4716e', 'isTrunk': True, 'transactions': []}

// Transaction
connector.getTransaction("0xda2ce6bddfb3bd32541c999e81ef56019a6314a23c90a466896aeefca33aebc1")

# >>> {'id': '0xda2ce6bddfb3bd32541c999e81ef56019a6314a23c90a466896aeefca33aebc1', 'chainTag': 39, 'blockRef': '0x00825266c5688208', 'expiration': 18, 'clauses': [{'to': '0x0000000000000000000000000000456e65726779', 'value': '0x0', 'data': '0xa9059cbb0000000000000000000000007567d83b7b8d80addcb281a71d54fc7b3364ffed0000000000000000000000000000000000000000000000056bc75e2d63100000'}], 'gasPriceCoef': 0, 'gas': 51582, 'origin': '0xfa6e63168115a9202dcd834f6c20eabf48f18ba7', 'delegator': None, 'nonce': '0x32c31a501fcd9752', 'dependsOn': None, 'size': 190, 'meta': {'blockID': '0x0082526895631e850b6cae1ba0a05deb24b8719b6896b69437cea87ee939bf3d', 'blockNumber': 8540776, 'blockTimestamp': 1615439010}}

// Transaction receipt
connector.getTransactionReceipt('0xda2ce6bddfb3bd32541c999e81ef56019a6314a23c90a466896aeefca33aebc1')

// >>> {'gasUsed': 36582, 'gasPayer': '0xfa6e63168115a9202dcd834f6c20eabf48f18ba7', 'paid': '0x1fbad5f2e25570000', 'reward': '0x984d9c8dd8008000', 'reverted': False, 'meta': {'blockID': '0x0082526895631e850b6cae1ba0a05deb24b8719b6896b69437cea87ee939bf3d', 'blockNumber': 8540776, 'blockTimestamp': 1615439010, 'txID': '0xda2ce6bddfb3bd32541c999e81ef56019a6314a23c90a466896aeefca33aebc1', 'txOrigin': '0xfa6e63168115a9202dcd834f6c20eabf48f18ba7'}, 'outputs': [{'contractAddress': None, 'events': [{'address': '0x0000000000000000000000000000456e65726779', 'topics': ['0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef', '0x000000000000000000000000fa6e63168115a9202dcd834f6c20eabf48f18ba7', '0x0000000000000000000000007567d83b7b8d80addcb281a71d54fc7b3364ffed'], 'data': '0x0000000000000000000000000000000000000000000000056bc75e2d63100000'}], 'transfers': []}]}

// Chain Tag
connector.getChainTag()
// >>> 39
```
## Debug a Failed Transaction

This operation will yield pretty revert reason if any.

```dart
import 'package:thor_request_dart/connect.dart';

connector = Connect("https://testnet.veblocks.net")
connector.replayTx("0x1d05a502db56ba46ccd258a5696b9b78cd83de6d0d67f22b297f37e710a72bb5")

// Notice: Revert Reason is decoded for you.

# [{
#     'data': '0x08c379a00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001c7472616e7366657220746f20746865207a65726f206164647265737300000000',
#     'events': [],
#     'transfers': [],
#     'gasUsed': 659,
#     'reverted': True,
#     'vmError': 'evm: execution reverted',
#     'decoded': {
#         'revertReason': 'transfer to the zero address'
#     }
# }]
```
# Examples (Smart Contract)

## Deploy a Smart Contract

```dart
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/wallet.dart';
import 'package:thor_request_dart/contract.dart';

connector = Connect("https://testnet.veblocks.net")

// wallet address: 0x7567d83b7b8d80addcb281a71d54fc7b3364ffed
_wallet = Wallet.fromPrivateKey(bytes.fromhex("dce1443bd2ef0c2631adc1c67e5c93f13dc23a41c18b536effbbdcbcdb96fb65")) 

_contract = Contract.fromFile("/path/to/solc/compiled/smart_contract.json")

res = connector.deploy(_wallet, _contract)
print(res)
// >>> {'id': '0xa670ae6fc053f3e63e9a944947d1e2eb9f53dc613fd305552ee00af987a6d140'}
```

## Call a Function (won't spend gas, emulate only)

```dart
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/contract.dart';

connector = Connect("https://testnet.veblocks.net")

_contract_addr = '0x535b9a56c2f03a3658fc8787c44087574eb381fd'
_contract = Contract.fromFile("/path/to/solc/compiled/smart_contract.json")
      
// Emulate the "balanceOf()" function
res = connector.call(
    '0x....', //fill in your caller address or all zero address
    _contract,
    "balanceOf",
    ['0x7567d83b7b8d80addcb281a71d54fc7b3364ffed'],
    to: _contract_addr,
)
print(res)

//Notice: The return value is decoded for you.
//
//{
//     'data': '0x0000000000000000000000000000000000000000000000006124fee993bc0004',
//     'events': [],
//     'transfers': [],
//     'gasUsed': 557,
//     'reverted': False,
//     'vmError': '',
//     'decoded': {
//         '0': 7000000000000000004
//     }
// }

// Emulate the "deposit()" function
res = connector.call(
    '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
    _contract,
    "deposit",
    [],
    to: _contract_addr,
    value: 4
)
print(res)

// Notice the Event is decoded for you.

/*
 {
     'data': '0x',
     'events': [{
         'address': '0x535b9a56c2f03a3658fc8787c44087574eb381fd',
         'topics': ['0xe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c', '0x0000000000000000000000007567d83b7b8d80addcb281a71d54fc7b3364ffed'],
         'data': '0x0000000000000000000000000000000000000000000000000000000000000004',
         'decoded': {
             '0': '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
             'dst': '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
            '1': 4,
             'wad': 4
         },
         'name': 'Deposit'
     }],
     'transfers': [{
         'sender': '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
         'recipient': '0x535b9a56c2f03a3658fc8787c44087574eb381fd',
         'amount': '0x4'
    }],
     'gasUsed': 6902,
     'reverted': False,
     'vmError': ''
 }
/*
```

## Execute a Function (spend real gas)

```dart
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/wallet.dart';
import 'package:thor_request_dart/contract.dart';

connector = Connect("https://testnet.veblocks.net")

// wallet address: 0x7567d83b7b8d80addcb281a71d54fc7b3364ffed
_wallet = Wallet.fromPrivateKey(bytes.fromhex("dce1443bd2ef0c2631adc1c67e5c93f13dc23a41c18b536effbbdcbcdb96fb65")) 
_contract_addr = '0x535b9a56c2f03a3658fc8787c44087574eb381fd'
_contract = Contract.fromFile("/path/to/solc/compiled/metadata.json")

// Execute the "deposit()" function. (will pay gas)
// Send along 5 VET with the tx
res = connector.transact(_wallet, _contract, "deposit", [], to: _contract_addr, value: 5 * (10^18))
print(res)

// >>> {'id': '0x51222328b7395860cb9cc6d69d822cf31056851b5694eeccc9f243021eecd547'}
```

## Send VET and VTHO (or any vip180 token)
```dart
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/wallet.dart';

connector = Connect("https://testnet.veblocks.net")

// wallet address: 0x7567d83b7b8d80addcb281a71d54fc7b3364ffed
_wallet = Wallet.fromPrivateKey(bytes.fromhex("dce1443bd2ef0c2631adc1c67e5c93f13dc23a41c18b536effbbdcbcdb96fb65")) 

// Transfer 3 VET to 0x0000000000000000000000000000000000000000
connector.transferVet(
    _wallet,
    '0x0000000000000000000000000000000000000000',
    value: 3 * (10^18)
)

// Transfer 3 VTHO to 0x0000000000000000000000000000000000000000
connector.transferVtho(
    _wallet, 
    '0x0000000000000000000000000000000000000000',
    vthoInWei: 3 * (10^18)
)

// Transfer 3 OCE to 0x0000000000000000000000000000000000000000
connector.transferToken(
    _wallet, 
    '0x0000000000000000000000000000000000000000',
    tokenContractAddress: '0x0ce6661b4ba86a0ea7ca2bd86a0de87b0b860f14', // OCE smart contract
    amountInWei: 3 * (10^18)
)

// Check VET or VTHO balance of an address: 0x0000000000000000000000000000000000000000
amount_vet = connector.getVetBalance('0x0000000000000000000000000000000000000000')
amount_vtho = connector.getVthoBalance('0x0000000000000000000000000000000000000000')
```

## VIP-191 Fee Delegation Feature (I)
```dart
// Sign a local transaction if you have:
// 1) Wallet to originate the transaction
// 2) Wallet to pay for the gas fee

import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/wallet.dart';
import 'package:thor_request_dart/contract.dart';

connector = Connect("https://testnet.veblocks.net")

// wallet 1: The transaction sender
_sender = Wallet.fromMnemonic(words=['...', '...', ... ]) 

// wallet 2: The transaction fee payer
_payer = Wallet.fromPrivateKey(bytes.fromhex("dce1443bd2ef0c2631adc1c67e5c93f13dc23a41c18b536effbbdcbcdb96fb65")) 

// Smart contract
_contract_addr = '0x535b9a56c2f03a3658fc8787c44087574eb381fd'
_contract = Contract.fromFile("/path/to/solc/compiled/metadata.json")

// For example, 
// "The sender" execute the "deposit()" function on the smart contract, with 5 VET within the transaction
// Transaction paid by "the payer".
res = connector.transact(
    _sender,
    _contract,
    "deposit",
    [],
    to: _contract_addr,
    value: 5 * (10^18),
    gasPayer: _payer
)
print(res)
// >>> {'id': '0x51222328b7395860cb9cc6d69d822cf31056851b5694eeccc9f243021eecd547'}
```




## VIP-191 Fee Delegation Feature (II)

```dart
// Quickly send VET or VTHO using fee delegation

import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/wallet.dart';

connector = Connect("https://testnet.veblocks.net")

// sender wallet
_sender = Wallet.fromMnemonic(words=['...', '...', ... ])

// gas payer wallet
_payer = Wallet.fromPrivateKey(bytes.fromhex("dce1443bd2ef0c2631adc1c67e5c93f13dc23a41c18b536effbbdcbcdb96fb65")) 

// Transfer 3 VET from _sender to 0x0000000000000000000000000000000000000000
connector.transferVet(
    _sender,
    '0x0000000000000000000000000000000000000000',
    value: 3 * (10^18),
    gasPayer: _payer
)

// Transfer 3 VTHO from _sender to 0x0000000000000000000000000000000000000000
connector.transferVtho(
    _sender, 
    '0x0000000000000000000000000000000000000000',
    vthoInWei: 3 * (10^18),
    gasPayer: _payer
)
```