import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:thor_devkit_dart/crypto/keccak.dart';
import 'package:thor_devkit_dart/crypto/secp256k1.dart';
import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/wallet.dart';

void main() {
  test('Wallet from Mnemonic phrase', () {
    List<String> words = [
      'share',
      'adjust',
      'glass',
      'dilemma',
      'adapt',
      'frost',
      'furnace',
      'tip',
      'embrace',
      'fatal',
      'grit',
      'comic',
      'clay',
      'frog',
      'extend',
      'funny',
      'kick',
      'wide',
      'off',
      'cloth',
      'bridge',
      'maid',
      'strong',
      'acquire',
    ];
    var priv = hexToBytes(
        'b724aa16d6face0f461ce2245b60bbfcd8676ec96e8fef615ea626e0aa88cbf0');
    Wallet wallet = Wallet.fromMnemonic(words);
    expect(wallet.priv, priv);
  });

  test('Wallet from keystore', () {
    var priv = hexToBytes(
        '1599403f7b6c17bb09f16e7f8ebe697af3626db5b41e0f9427a49151c6216920');
    Map ks = {
      "crypto": {
        "cipher": "aes-128-ctr",
        "cipherparams": {"iv": "6a21f87e834cc83d4e50ea50842b1154"},
        "ciphertext":
            "8bebd60603b5f3a093ab8c8d9650cdfa2eab530a6abe29b1ac77d8693f2f7798",
        "kdf": "scrypt",
        "kdfparams": {
          "dklen": 32,
          "n": 8192,
          "r": 8,
          "p": 1,
          "salt":
              "4fa66a9713b85e9917dc02c9903399bc11d2634311fc955399c4fdd88238ad94"
        },
        "mac":
            "9ebe2cc5ff466cd2d82124cc94039901e0004771dfb0e5c66985f36c18573882"
      },
      "id": "eef240d8-d2a5-4fd5-97b5-41bc859a0c0c",
      "version": 3
    };
    Wallet wallet = Wallet.fromKeystore(json.encode(ks), '123456');
    expect(wallet.priv, priv);
  });

  test('generte new wallet', () {
    Wallet wallet = Wallet.newWallet();
    expect(isValidPrivateKey(wallet.priv), true);
  });

  test('sign and verify sig', () {
    Wallet wallet = Wallet.newWallet();
    expect(isValidPrivateKey(wallet.priv), true);

    final msgHash =
        keccak256([Uint8List.fromList(utf8.encode('this is a test!'))]);

    final sig = wallet.sign(msgHash);
    expect(wallet.verifySignature(msgHash, sig), true);
  });
}
