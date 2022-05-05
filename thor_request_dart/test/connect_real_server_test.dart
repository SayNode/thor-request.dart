import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:thor_devkit_dart/crypto/blake2b.dart';
import 'package:thor_devkit_dart/crypto/secp256k1.dart';
import 'package:thor_devkit_dart/crypto/thor_signature.dart';
import 'package:thor_devkit_dart/transaction.dart';
import 'package:thor_devkit_dart/types/clause.dart';
import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/contract.dart';
import 'package:thor_request_dart/wallet.dart';

void main() {

  test('emulate', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map b = json.decode(File("assets/json_test/tx.json").readAsStringSync());
    var a = await connect.emulate(b);
    expect(json.encode(a),
        '[{"data":"0x","events":[],"transfers":[],"gasUsed":0,"reverted":false,"vmError":""}]');
  });

  test('replayTx with reason', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map b = json.decode(File("assets/json_test/tx.json").readAsStringSync());

    var a = await connect.replayTx(
        "0x1d05a502db56ba46ccd258a5696b9b78cd83de6d0d67f22b297f37e710a72bb5");
    expect(a[0]['decoded']['revertReason'], "transfer to the zero address");
  });

  test('emulte transaction', () async {
    Map txBody =
        json.decode(File("assets/json_test/tx.json").readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
    var a = await connect.emulateTx(
        '0x5034aa590125b64023a0262112b98d72e3c8e40e', txBody);
    Map matcher = {
      'data': '0x',
      'events': [],
      'transfers': [],
      'gasUsed': 0,
      'reverted': false,
      'vmError': ''
    };
    expect(a, [matcher]);
  });

  test('call', () async {
    Map contractMeta =
        json.decode(File("assets/json_test/VVET9.json").readAsStringSync());
    Connect connect = Connect('https://testnet.veblocks.net');
    Contract contract = Contract(contractMeta);

    var a = await connect.call('0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
        contract, 'deposit', [], '0x5034aa590125b64023a0262112b98d72e3c8e40e');
    Map matcher = {
      'data': '0x',
      'events': [],
      'transfers': [],
      'gasUsed': 0,
      'reverted': false,
      'vmError': ''
    };
    expect(a, matcher);
  });

  test('call address input', () async {
    Map contractMeta =
        json.decode(File("assets/json_test/VVET9.json").readAsStringSync());
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

  test('post transaction', () async {
    List<Clause> clauses = [
      Clause("0x0000000000000000000000000000000000000000",
          "1000000000000000000", "0x"),
    ];
    Transaction tx = Transaction(39, "0x00634b0a00639801", "72000000", clauses,
        "0", "21000", null, "12345678", null);
    Uint8List privateKey = hexToBytes(
        "7582be841ca040aa940fff6c05773129e135623e41acce3e0b8ba520dc1ae26a");
    Uint8List h = blake2b256([tx.encode()]);
    Uint8List sig = sign(h, privateKey).serialize();
    tx.signature = sig;
    String raw = '0x' + bytesToHex(tx.encode());
    Connect connect = Connect('https://testnet.veblocks.net');
   // var a = await connect.postTransaction(raw);
    //print(a);
  });

  test('transfer VET test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Wallet wallet = Wallet(hexToBytes(
        '7582be841ca040aa940fff6c05773129e135623e41acce3e0b8ba520dc1ae26a'));
    print(await connect.transferVet(
        wallet, '0x5034aa590125b64023a0262112b98d72e3c8e40e', value: BigInt.parse('37000000000000000000')),); 
  });
  test('transfer VTHO test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    print(await connect.transferVtho(
        wallet, '0x5034aa590125b64023a0262112b98d72e3c8e40e'));
        print(await connect.waitForTxReceipt('0x3c13b9db88babe6c3a74a42aec5202d6f664c9493a5a950f15ce166ac83006fe'));
  });
  test('transfer Token test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    print(await connect.transferToken(
        wallet,
        '0x5034aa590125b64023a0262112b98d72e3c8e40e',
        '0x5034aa590125b64023a0262112b98d72e3c8e40e'));
  });

    test('deploy contract', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));

    BigInt value = BigInt.from(0);
    var a = await connect.deploy(wallet, Contract.fromFilePath('assets/json_test/Vidar.json'), ['string', 'address'], ['Vidar', '0x17ACC76e4685AEA9d574705163E871b83e36697f'], BigInt.zero);
    print(a);
  });



}


