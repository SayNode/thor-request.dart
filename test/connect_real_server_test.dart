import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:thor_devkit_dart/crypto/blake2b.dart';
import 'package:thor_devkit_dart/crypto/secp256k1.dart';
import 'package:thor_devkit_dart/transaction.dart';
import 'package:thor_devkit_dart/types/clause.dart';
import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/connect.dart';
import 'package:thor_request_dart/contract.dart';
import 'package:thor_request_dart/utils.dart';
import 'package:thor_request_dart/wallet.dart';

void main() {
  String nodeUrl = 'http://testnet.vechain.blockorder.net';
  test('emulate', () async {
    Connect connect = Connect(nodeUrl);
    Map b = json.decode(File("assets/json_test/tx.json").readAsStringSync());
    var a = await connect.emulate(b);
    expect(json.encode(a),
        '[{"data":"0x","events":[],"transfers":[],"gasUsed":0,"reverted":false,"vmError":""}]');
  });

  test('replayTx with reason', () async {
    Connect connect = Connect(nodeUrl);

    var a = await connect.replayTx(
        "0x1d05a502db56ba46ccd258a5696b9b78cd83de6d0d67f22b297f37e710a72bb5");
    expect(a[0]['decoded']['revertReason'], "transfer to the zero address");
  });

  test('emulte transaction', () async {
    Map txBody =
        json.decode(File("assets/json_test/tx.json").readAsStringSync());
    Connect connect = Connect(nodeUrl);
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
    Connect connect = Connect(nodeUrl);
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
    Connect connect = Connect(nodeUrl);
    Contract contract = Contract(contractMeta);

    Map a = await connect.call(
        '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
        contract,
        'balanceOf',
        ['0x5034aa590125b64023a0262112b98d72e3c8e40e'],
        '0x5034aa590125b64023a0262112b98d72e3c8e40e');

    String matcher =
        """{"data":"0x","events":[],"transfers":[],"gasUsed":0,"reverted":false,"vmError":""}""";

    expect(json.encode(a), matcher);
  });

  test('post transaction', () async {
    Connect connect = Connect(nodeUrl);
    List<Clause> clauses = [
      Clause("0x0000000000000000000000000000000000000000",
          "1000000000000000000", "0x"),
    ];

    //Blockref +1 before test
    Transaction tx = Transaction(39, "0x00634b0a00639804", "72000000", clauses,
        "0", "21000", null, "12345678", null);
    Uint8List privateKey = hexToBytes(
        "7582be841ca040aa940fff6c05773129e135623e41acce3e0b8ba520dc1ae26a");
    Uint8List h = blake2b256([tx.encode()]);
    Uint8List sig = sign(h, privateKey).serialize();
    tx.signature = sig;
    String raw = '0x' + bytesToHex(tx.encode());

    var a = await connect.postTransaction(raw);
    expect(isHexString(a['id']), true);
  });

  test('transfer VET test', () async {
    Connect connect = Connect(nodeUrl);
    Wallet wallet = Wallet(hexToBytes(
        '7582be841ca040aa940fff6c05773129e135623e41acce3e0b8ba520dc1ae26a'));
    var a = await connect.transferVet(
        wallet, '0x5034aa590125b64023a0262112b98d72e3c8e40e',
        value: BigInt.parse('37000000000000000000'));

    expect(isHexString(a['id']), true);
  });
  test('transfer VTHO test', () async {
    Connect connect = Connect(nodeUrl);
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    var a = await connect.transferVtho(
        wallet, '0x5034aa590125b64023a0262112b98d72e3c8e40e');

    expect(isHexString(a['id']), true);
  });

  test('recipt test', () async {
    Connect connect = Connect(nodeUrl);
    Wallet wallet = Wallet(hexToBytes(
        '7582be841ca040aa940fff6c05773129e135623e41acce3e0b8ba520dc1ae26a'));
    var res = await connect.transferVet(
        wallet, '0x5034aa590125b64023a0262112b98d72e3c8e40e',
        value: BigInt.parse('37000000000000000000'));
    var receiptRes = await connect.waitForTxReceipt(res['id']);

    expect(
        receiptRes!['gasPayer'], '0xd989829d88b0ed1b06edf5c50174ecfa64f14a64');
  });

  test('transfer Token test', () async {
    Connect connect = Connect(nodeUrl);
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    var a = await connect.transferToken(
        wallet,
        '0x5034aa590125b64023a0262112b98d72e3c8e40e',
        '0x5034aa590125b64023a0262112b98d72e3c8e40e');

    expect(isHexString(a['id']), true);
  });

  test('deploy contract', () async {
    Connect connect = Connect(nodeUrl);
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    var a = await connect.deploy(
        wallet,
        Contract.fromFilePath('assets/json_test/Vidar.json'),
        ['string', 'address'],
        ['Vidar', '0x17ACC76e4685AEA9d574705163E871b83e36697f'],
        BigInt.zero);
    expect(isHexString(a['id']), true);
  });

  test('type encoding', () {
    var a = buildParams(['uint32', 'bool'], [69, true]);
    expect(bytesToHex(a),
        '00000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001');
  });

  test('transact Multiple', () async {
    Connect connect = Connect(nodeUrl);
    Wallet wallet = Wallet(hexToBytes(
        '27196338e7d0b5e7bf1be1c0327c53a244a18ef0b102976980e341500f492425'));
    List<Clause> clauses = [
      Clause("0x0000000000000000000000000000000000000000",
          "1000000000000000000", "0x"),
      Clause("0x0000000000000000000000000000000000000000",
          "1000000000000000000", "0x")
    ];
    var a = await connect.transactMulti(wallet, clauses);
    expect(isHexString(a['id']), true);
  });

  test('Tuple test', () async {
    Connect connect = Connect(nodeUrl);
    Map contractMeta =
        json.decode(File("assets/json_test/tuple_abi.json").readAsStringSync());

    Contract contract = Contract(contractMeta);
    var res = await connect.call(
        '0x7567d83b7b8d80addcb281a71d54fc7b3364ffed',
        contract,
        'tuplesTesting',
        [
          [
            '0xEd44d91A96b5202E2572B8f99Ce92f48080Ceb5A',
            BigInt.zero,
            BigInt.one
          ]
        ],
        '0xEd44d91A96b5202E2572B8f99Ce92f48080Ceb5A');
    print(res);
  });
}
