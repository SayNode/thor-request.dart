import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thor_request_dart/contract.dart';

void main() {
  test('get contract from file path', () {
    Map jsonMap = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/UniswapV2Pair.json")
        .readAsStringSync());
    Contract contract = Contract.fromFilePath(
        "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/UniswapV2Pair.json");

    expect(contract.contractMeta, jsonMap);
  });

  test('get name from old style json', () {
    Contract contract = Contract.fromFilePath(
        "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/VVET9.json");
    expect(contract.getContractName(), 'VVET9');
  });

  test('get name from new style json', () {
    Contract contract = Contract.fromFilePath(
        "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/UniswapV2Pair.json");
    expect(contract.getContractName(), 'UniswapV2Pair');
  });

  test('get abis', () {
    Contract contract = Contract.fromFilePath(
        "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/VVET9.json");
    contract.getAbis();
  });
}
