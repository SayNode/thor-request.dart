import 'package:thor_devkit_dart/utils.dart';
import 'package:thor_request_dart/contract.dart';
import 'package:thor_devkit_dart/types/clause.dart' as dev;

class RClause {
  late Map clause;
  String? functionName;
  late BigInt value;
  late bool isCall;
  Contract? contract;

  RClause(String to,
      {this.contract,
      this.functionName,
      List? functionParameters,
      BigInt? value}) {
    value ??= BigInt.zero;
    isCall = contract != null && functionName != null;

    if (isCall) {
      var f = contract!.getFunctionByName(functionName!);
      var data = f.encode(functionParameters!);

      clause = {
        "to": to,
        "value": value.toString(),
        "data": "0x" + bytesToHex(data)
      };
    } else {
      clause = {"to": to, "value": value.toString(), "data": "0x"};
    }
  }

  dev.Clause getDevClause() {
    var c = dev.Clause(clause['to'], clause['value'], clause['data']);
    return c;
  }
}
