import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:thor_devkit_dart/crypto/address.dart';
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/contract.dart';
import 'package:web3dart/contracts.dart';

void main() {
  //TODO:write proper test
  test('emulate', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map b = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/tx.json")
        .readAsStringSync());
    var a = await connect.emulate(b);
    print(a);
  });

  test('replayTx with reason', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map b = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/tx.json")
        .readAsStringSync());

    var a = await connect.replayTx(
        "0x1d05a502db56ba46ccd258a5696b9b78cd83de6d0d67f22b297f37e710a72bb5");
    expect(a[0]['decoded']['revertReason'], "transfer to the zero address");
  });

  test('emulte trnsaction', () async {
    Map txBody = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/tx.json")
        .readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
    var a = await connect.emulateTx(
        '0x5034aa590125b64023a0262112b98d72e3c8e40e', txBody);
    print(a);
  });

  test('call', () async {
        Map contractMeta = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/VVET9.json")
        .readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
    Contract contract = Contract(contractMeta);
    
    var a = await connect.call('0x7567d83b7b8d80addcb281a71d54fc7b3364ffed', contract, 'deposit', [], '0x5034aa590125b64023a0262112b98d72e3c8e40e');
  print(a);
  
  });

    test('call address input', () async {
        Map contractMeta = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/VVET9.json")
        .readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
    Contract contract = Contract(contractMeta);
    
    var a = await connect.call('0x7567d83b7b8d80addcb281a71d54fc7b3364ffed', contract, 'balanceOf', ['0x5034aa590125b64023a0262112b98d72e3c8e40e'], '0x5034aa590125b64023a0262112b98d72e3c8e40e');
  print(a);
  
  });
}
