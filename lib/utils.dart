import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:thor_devkit_dart/crypto/address.dart';
import 'package:thor_devkit_dart/crypto/blake2b.dart';
import 'package:thor_devkit_dart/crypto/secp256k1.dart';
import 'package:thor_devkit_dart/transaction.dart';
import 'package:thor_devkit_dart/types/clause.dart';
import 'package:thor_devkit_dart/types/reserved.dart';
import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/codec.dart';
import 'package:thor_request_dart/contract.dart';
import 'package:thor_request_dart/wallet.dart';

Map injectRevertReason(Map emulateResponse) {
  if (emulateResponse["reverted"] == true && emulateResponse["data"] != "0x") {
    String encodedRevertReason = emulateResponse['data'].substring(138);
    String decoded = utf8.decode(hexToBytes(encodedRevertReason));
    decoded = decoded.replaceAll('\x00', '');
    emulateResponse["decoded"] = {"revertReason": decoded};
  }

  return emulateResponse;
}

///Rip an emulated tx body from a normal tx body.
Map calcEmulateTxBody(String caller, Map txBody, {String? gaspayer}) {
  if (!Address.isAddress(caller)) {
    throw Exception('Caller $caller is not an address');
  }

  //Caution: in emulation, clauses.clause.value must be of type string
  var eClauses = [];
  for (var clause in txBody['clauses']) {
    if (clause is String) {
      Map c = json.decode(clause);

      eClauses.add(
          {'to': c['to'], 'value': c['value'].toString(), 'data': c['data']});
    } else {
      eClauses.add({
        'to': clause['to'],
        'value': clause['value'].toString(),
        'data': clause['data']
      });
    }
  }

  var eTxBody = {
    "caller": caller,
    "blockRef": txBody["blockRef"],
    "expiration": txBody["expiration"],
    "clauses": eClauses,
  };

  // Set gas field only when the txBody set it.
  if (txBody["gas"] > 0) {
    eTxBody["gas"] = txBody["gas"];
  }

  // Set gas payer only when required.
  if (gaspayer != null) {
    if (!Address.isAddress(gaspayer)) {
      throw Exception("Gaspayer $gaspayer is not an address");
    }
    eTxBody["gasPayer"] = gaspayer;
  }
  return eTxBody;
}

///Build a Tx body.
///Clause should confine to "thor_devkit.transaction.CLAUSE" schema. {to, value, data}
/// Tx body shall confine to "thor_devkit.transaction.BODY" schema.

Map buildTxBody(List clauses, int chainTag, String blockRef, int nonce,
    {int expiration = 32,
    int gasPriceCoef = 0,
    int gas = 0,
    String? dependsOn,
    bool feeDelegation = false}) {
  var body = {
    "chainTag": chainTag,
    "blockRef": blockRef,
    "expiration": expiration,
    "clauses": clauses,
    "gasPriceCoef": gasPriceCoef,
    "gas": gas,
    "dependsOn": dependsOn,
    "nonce": nonce,
  };
  if (feeDelegation) {
    body['reserved'] = {'features': 1};
  }

  return body;
}

Transaction buildTransaction(
    List<Clause> clauses, int chainTag, String blockRef, int nonce,
    {int expiration = 32,
    int gasPriceCoef = 0,
    int gas = 0,
    String? dependsOn,
    bool feeDelegation = false}) {
  Reserved reserved;
  if (!feeDelegation) {
    reserved = Reserved.getNullReserved();
  } else {
    reserved = Reserved(1, []);
  }
  Transaction tx = Transaction(
      chainTag,
      blockRef,
      expiration.toRadixString(10),
      clauses,
      gasPriceCoef.toRadixString(10),
      gas.toRadixString(10),
      dependsOn,
      nonce.toRadixString(10),
      reserved);

  return tx;
}

///Calculate a blockRef from a given block_id, id should starts with 0x
String calcBlockRef(String blockId) {
  if (!blockId.startsWith("0x")) {
    throw Exception("block_id should start with 0x");
  }

  return blockId.substring(0, 18);
}

///Calculate a random number for nonce
int calcNonce() {
  final random = Random.secure();
  int length = 8;
  String chars = '0123456789ABCDEF';
  String hex = '';
  while (length-- > 0) {
    hex += chars[(random.nextInt(16)) | 0];
  }
  return int.parse(hex, radix: 16);
}

///If a single clause emulation is failed
bool isEmulateFailed(emulateResponse) {
  return emulateResponse["reverted"];
}

///Check the emulate response, if any tx reverted then it is a fail
bool anyEmulateFailed(List emulateResponses) {
  for (var item in emulateResponses) {
    if (isEmulateFailed(item)) {
      return true;
    }
  }
  return false;
}

///Inject 'decoded' return value into a emulate response
Map injectDecodedReturn(
    Map emulateResponse, Contract contract, String funcName) {
  if (emulateResponse["reverted"] == true) {
    return emulateResponse;
  }

  if ((emulateResponse["data"] == null) ||
      (emulateResponse["data"] == "0x")) {
    return emulateResponse;
  }
  var functionObj = contract.getFunctionByName(funcName);
  var wrapperList = functionObj.decodeReturnV1(emulateResponse["data"]);
  Map decoded = {};
  for (var i = 0; i < wrapperList.length; i++) {
    decoded[i] =  wrapperList[i].value;
  }
  // for (var obj in wrapperList) {
  //   decoded[obj.name] = obj.value;
  // }

  emulateResponse["decoded"] = decoded;

  return emulateResponse;
}

///Inject 'decoded' and 'name' into event
Map injectDecodedEvent(Map eventDict, Contract contract) {
  var eObj = contract.getEventBySignature(hexToBytes(eventDict["topics"][0]));

  // otherwise can be decoded
  eventDict["decoded"] = eObj.decodeResults(
    eventDict["data"],
    eventDict["topics"],
  );
  eventDict["name"] = eObj.event.name;
  return eventDict;
}

///Extract vm gases from a batch of emulated executions.
List<int> readVmGases(List emulatedResponses) {
  List<int> results = [];
  for (var item in emulatedResponses) {
    if (item["gasUsed"] is int) {
      results.add(item["gasUsed"]);
    } else {
      results.add(int.parse(item["gasUsed"]));
    }
  }

  return results;
}

///Calculate the suggested gas for a transaction
int suggestGasForTx(int vmGas, Map txBody) {
  Transaction tx = Transaction.fromJsonString(json.encode(txBody));
  var intrincisGas = tx.getIntrinsicGas();
  var supposedSafeGas = calcGas(vmGas, intrincisGas);
  return supposedSafeGas;
}

///Calculate recommended (safe) gas
int calcGas(int vmGas, int intrinsicGas) {
  return vmGas + intrinsicGas + 15000;
}

///Build signed transaction from tx body
Transaction calcTxSigned(Wallet wallet, Map txBody) {
  Transaction tx = Transaction.fromJsonString(json.encode(txBody));
  //var message_hash = tx.getSigningHash(null);
  var msgHash = blake2b256([tx.encode()]);
  //var signature = wallet.sign(msgHash);
  Uint8List sig = sign(msgHash, wallet.priv).serialize();
  tx.signature = sig;
  return tx;
}

///Build signed transaction from tx body
String calcTxSignedEncoded(Wallet wallet, Map txBody) {
  var tx = calcTxSigned(wallet, txBody);

  var txBytes = tx.encode();
  var txHex = bytesToHex(txBytes);
  String txEncoded = '0x' + txHex;
  return txEncoded;
}

Transaction calcTxSignedWithFeeDelegation(
    Wallet caller, Wallet payer, Transaction tx) {
  assert(tx.isDelegated() == true);

  var callerHash = tx.getSigningHash(null);
  var payerHash = tx.getSigningHash(caller.adressString.toLowerCase());

  var finalSig = caller.sign(callerHash) + payer.sign(payerHash);

  tx.signature = Uint8List.fromList(finalSig);

  assert(tx.getOriginAsAddressString()!.toLowerCase() ==
      caller.adressString.toLowerCase());
  assert(tx.getDelegatorAsAddressString()!.toLowerCase() ==
      payer.adressString.toLowerCase());

  return tx;
}


///ABI encode params according to types
Uint8List buildParams(List<String> types, List args) {
  if (types.length != args.length) {
    throw Exception('types and args length has to be the same');
  }

  List<int> out = [];

  for (var i = 0; i < types.length; i++) {
    out.addAll(encodeType(types[i], args[i]));
  }

  return Uint8List.fromList(out);
}
