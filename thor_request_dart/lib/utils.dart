import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:thor_devkit_dart/crypto/address.dart';
import 'package:thor_devkit_dart/function.dart';
import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/contract.dart';

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
    eClauses.add({
      'to': clause['to'],
      'value': clause['value'].toString(),
      'data': clause['data']
    });
  }

  var eTxBody = {
    "caller": caller,
    "blockRef": txBody["blockRef"],
    "expiration": txBody["expiration"],
    "clauses": eClauses,
  };

  // Set gas field only when the txBody set it.
  if (int.parse(txBody["gas"]) > 0) {
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

Map build_tx_body(List clauses, int chainTag, String blockRef, BigInt nonce,
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
    "gas": gas.toString(),
    "dependsOn": dependsOn,
    "nonce": nonce,
  };
  if (feeDelegation) {
    body['reserved'] = {'features': 1};
  }

  return body;
}

///Calculate a blockRef from a given block_id, id should starts with 0x
String calc_blockRef(String block_id) {
  if (!block_id.startsWith("0x")) {
    throw Exception("block_id should start with 0x");
  }

  return block_id.substring(0, 18);
}

///Calculate a random number for nonce
BigInt calc_nonce() {
  final random = Random.secure();
  final builder = BytesBuilder();
  for (var i = 0; i < 8; ++i) {
    builder.addByte(random.nextInt(256));
  }
  final bytes = builder.toBytes();
  return bytesToInt(bytes);
}

///If a single clause emulation is failed
bool is_emulate_failed(emulate_response) {
  return emulate_response["reverted"];
}

///Check the emulate response, if any tx reverted then it is a fail
bool any_emulate_failed(List emulate_responses) {
  for (var item in emulate_responses) {
    if (is_emulate_failed(item)) {
      return true;
    }
  }
  return false;
}

///Inject 'decoded' return value into a emulate response
Map inject_decoded_return(
    Map emulate_response, Contract contract, String func_name) {
  if (emulate_response["reverted"] == true) {
    return emulate_response;
  }
  if ((emulate_response["data"] != null) ||
      (emulate_response["data"] == "0x")) {
    return emulate_response;
  }
  var function_obj = contract.getFunctionByName(func_name);
  emulate_response["decoded"] =
      function_obj.decodeReturn(emulate_response["data"]);

  return emulate_response;
}

///Inject 'decoded' and 'name' into event
Map inject_decoded_event(Map event_dict, Contract contract) {
  var e_obj = contract.getEventBySignature(hexToBytes(event_dict["topics"][0]));
  if (e_obj == null) {
    return event_dict;
  } // oops, event not found, cannot decode

  // otherwise can be decoded
  event_dict["decoded"] = e_obj.decodeResults(
    event_dict["data"],
    event_dict["topics"],
  );
  event_dict["name"] = e_obj.event.name;
  return event_dict;
}
