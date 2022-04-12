import 'dart:typed_data';
import 'package:thor_devkit_dart/crypto/address.dart';
import 'package:thor_devkit_dart/crypto/keystore.dart';
import 'package:thor_devkit_dart/crypto/mnemonic.dart';
import 'package:thor_devkit_dart/crypto/secp256k1.dart' as secp256k1;
import 'package:thor_devkit_dart/crypto/thor_signature.dart';
import 'package:thor_devkit_dart/utils.dart';

class Wallet {
//TODO: check if all this is needed as class parameter
  late Uint8List priv;
  late Uint8List pub;
  late Uint8List adressBytes;
  late String adressString;

  ///Create Wallet from private Key [priv]
  Wallet(this.priv) {
    if (priv.length != 32) {
      throw Exception("Private key should be 32 bytes");
    }

    pub = secp256k1.derivePublicKey(bytesToInt(priv), false);
    adressBytes = publicKeyToAddressBytes(pub);
    adressString = publicKeyToAddressString(pub);
  }

  ///Generate Wallet from Mnemonic phrase
  static Wallet fromMnemonic(List<String> words) {
    if (!Mnemonic.validate(words)) {
      throw Exception('Invalis Mnemonic phrase');
    }

    var priv = Mnemonic.derivePrivateKey(words);
    return Wallet(priv);
  }

  ///Generate Wallet from [keyStore]
  ///[keyStore] is a jsonString
  static Wallet fromKeystore(String keyStore, String password) {
    var priv = KeyStore().decrypt(keyStore, password);
    return Wallet(priv);
  }

  ///create new wallet from scratch
  static Wallet newWallet() {
    var priv = secp256k1.generatePrivateKey();
    return Wallet(intToBytes(priv));
  }

  Uint8List sign(Uint8List msgHash) {
    var sig = secp256k1.sign(msgHash, priv);
    return sig.serialize();
  }

  bool verifySignature(Uint8List msgHash, Uint8List sig) {
    var pub = secp256k1.recover(msgHash, ThorSignature.fromBytes(sig));
    return this.pub == pub;
  }
}
