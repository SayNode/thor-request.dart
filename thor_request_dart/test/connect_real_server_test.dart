import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:thor_devkit_dart/crypto/address.dart';
import 'package:thor_devkit_dart/transaction.dart';
import 'package:thor_devkit_dart/types/clause.dart';
import 'package:thor_devkit_dart/types/rlp.dart';
import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/contract.dart';
import 'package:thor_request_dart/wallet.dart';
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

  test('emulte transaction', () async {
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

    var a = await connect.call('0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
        contract, 'deposit', [], '0x5034aa590125b64023a0262112b98d72e3c8e40e');
    print(a);
  });

  test('call address input', () async {
    Map contractMeta = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/VVET9.json")
        .readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
    Contract contract = Contract(contractMeta);

    var a = await connect.call(
        '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
        contract,
        'balanceOf',
        ['0x5034aa590125b64023a0262112b98d72e3c8e40e'],
        '0x5034aa590125b64023a0262112b98d72e3c8e40e');
    print(a);
  });

  test('post', () async {
    Map contractMeta = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/VVET9.json")
        .readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
var ct = "ba";
    var raw =
        "0xf86981$ct" + "800adad994000000000000000000000000000000000000746f82271080018252088001c0b8414792c9439594098323900e6470742cd877ec9f9906bca05510e421f3b013ed221324e77ca10d3466b32b1800c72e12719b213f1d4c370305399dd27af962626400";

    var a = await connect.postTransaction(raw);
    print(a);
  });

    test('transfer VET test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Wallet wallet = Wallet(hexToBytes('27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    print(await connect.transferVet(wallet, '0x5034aa590125b64023a0262112b98d72e3c8e40e'));
  });

}
