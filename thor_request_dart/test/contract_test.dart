import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thor_devkit_dart/function.dart';
import 'package:thor_request_dart/contract.dart';

void main() {
  test('get contract from file path', () {
    Map jsonMap = json.decode(File(
            "assets/json_test/UniswapV2Pair.json")
        .readAsStringSync());
    Contract contract = Contract.fromFilePath(
        "assets/json_test/UniswapV2Pair.json");

    expect(contract.contractMeta, jsonMap);
  });

  test('get name from old style json', () {
    Contract contract = Contract.fromFilePath(
        "assets/json_test/VVET9.json");
    expect(contract.getContractName(), 'VVET9');
  });

  test('get name from new style json', () {
    Contract contract = Contract.fromFilePath(
        "assets/json_test/UniswapV2Pair.json");
    expect(contract.getContractName(), 'UniswapV2Pair');
  });


    test('get specific abi', () {
    Contract contract = Contract.fromFilePath(
        "assets/json_test/VVET9.json");

    Map abiMatcher =       {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "src",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "guy",
            "type": "address"
          },
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "wad",
            "type": "uint256"
          }
        ],
        "name": "Approval",
        "type": "event"
      };
    Map abi = contract.getAbi('Approval');
    expect(abi, abiMatcher);

  });

    test('function by name', () {
      Map functionMatcher =       {
        "constant": true,
        "inputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "name": "allowance",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      };

    Contract contract = Contract.fromFilePath(
        "assets/json_test/UniswapV2Pair.json");
        print(ThorFunction(json.encode(functionMatcher)).function.toString());
    expect(contract.getFunctionByName('allowance').function.name, ThorFunction(json.encode(functionMatcher)).function.name);


    //no bi with this name
    expect(() => contract.getFunctionByName('lakeusjwegw'), throwsException);

    //abi with this name is not a function
    expect(() => contract.getFunctionByName('Approval'), throwsException);

  });

  
  


}
