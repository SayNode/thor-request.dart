import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:thor_devkit_dart/event.dart';
import 'package:thor_devkit_dart/function.dart';
import 'package:thor_devkit_dart/utils.dart';

class Contract {
  late Map contractMeta;

  Contract(this.contractMeta);

  static Contract fromJsonString(String jsonString) {
    return Contract(json.decode(jsonString));
  }

  ///get contract from json file located at [path]
  static Contract fromFilePath(String path) {
    //get file from path
    File data = File(path);
    //read file content as string
    String jsonString = data.readAsStringSync();

    return Contract(json.decode(jsonString));
  }

  ///Get the smart contract Name or null
  String? getContractName() {
    //old style json
    if (contractMeta["contractName"] != null) {
      return contractMeta['contractName'];
    }

    //new style json

    if (contractMeta['metadata'] != null) {}
    var m = json.decode(contractMeta["metadata"]);

    if (m['settings'] != null && m['settings']['compilationTarget'] != null) {
      List keys = m["settings"]["compilationTarget"].keys.toList();

      return m["settings"]["compilationTarget"][keys[0]];
    }

    //if there is no name return null
    return null;
  }

  ///Get bytecode of this contract
  Uint8List getBytecode() {
    return hexToBytes(contractMeta['bytecode']);
  }

  ///Get list of ABIs of this contract
  List<Map> getAbis() {
    List<Map> out = [];
    for (var item in contractMeta['abi']) {
      out.add(item as Map);
    }

    return out;
  }

  ///Get ABI by [name]. Throws exception if no abi with this name exists for this contract
  Map getAbi(String name) {
    var abis = getAbis();
    List<Map> temp = [];
    for (var item in abis) {
      if (item['name'] == name) {
        temp.add(item);
      }
    }
    //it should not be possible for multiple ABIs to have the same name
    assert(temp.length < 2);

    //throw exception if ABI with this name was not found
    if (temp.isEmpty) {
      throw Exception('ABI with name $name was not found');
    }
    return temp[0];
  }

  ThorFunction getFunctionByName(String name) {
    var abi = getAbi(name);
    if (abi['type'] != 'function') {
      throw Exception('ABI with name $name is not a function');
    }
    return ThorFunction(json.encode(abi));
  }

  List<ThorEvent> getEvents() {
    List<ThorEvent> output = [];
    for (var item in getAbis()) {
      if (item['type'] == 'event') {
        output.add(ThorEvent(json.encode(item)));
      }
    }
    return output;
  }

  ThorEvent getEventBySignature(Uint8List sig) {
    var events = getEvents();
    for (var event in events) {
      if (event.getSignature() == sig) {
        return event;
      }
    }
    throw Exception('No event with this signature found.');
  }
}
